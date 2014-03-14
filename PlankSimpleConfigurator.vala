using Gtk;

public class INI {
	const int TYPE_VALUE = 1;
	const int TYPE_HEADER = 2;
	const int TYPE_COMMENT = 3;
	const int TYPE_EMPTYLINE = 4;

	private string[] Names;
	private string[] Values;
	private int[] Types;

	public string filename = "File not loaded!";

	public int load(string filename) {
		string filerawstr;
		string[] fileraw;
		string[] stringraw = new string[2];
		try {
			FileUtils.get_contents(filename, out filerawstr);
		} catch (Error e) {
			return e.code;
		}
		this.filename = filename;
		fileraw = filerawstr.split("\n");
		foreach (string str in fileraw) {
			switch(str[0]) {
				case '#':
					Types += TYPE_COMMENT;
					Names += str;
					Values += "";
					break;
				case '[':
					Types += TYPE_HEADER;
					Names += str;
					Values += "";
					break;
				default:
					if ("=" in str) {
						Types += TYPE_VALUE;
						stringraw = str.split("=");
						Names += stringraw[0];
						Values += stringraw[1];
					} else {
						Types += TYPE_EMPTYLINE;
						Names += "\n";
						Values += "";
					}
					break;
			}
		}
		return 0;
	}

	public int save(string filename) {
		string filerawstr = "";
		int i = 0;

		while (i < Names.length) {
			if (Types[i] == TYPE_VALUE) {
				filerawstr += (Names[i] + "=" + Values[i] + "\n");
			} else if (Types[i] == TYPE_EMPTYLINE) {
				filerawstr += "\n";
			} else {
				filerawstr += (Names[i] + "\n");
			}
			i++;
		}
		try {
			FileUtils.set_contents(filename, filerawstr);
		} catch (Error e) {
			GLib.stderr.printf("Error while saving file. Message: %s",e.message);
			return e.code;
		}
		return 0;
	}

	public string getByNameAndHeader(string Name, string Header) {
		int i = 0;
		bool inside = false;

		foreach (string str in Names) {
			if (inside) {
				if (str == Name) {
					return Values[i];
				}
			} else {
				if (Types[i] == TYPE_HEADER) {
					inside = (str == "[" + Header + "]");
				}
			}
			i++;
		}
		stderr.printf("Can't get value by name and header!");
		return "";
	}

	public void setByNameAndHeader(string Name, string Header, string Value) {
		int i = 0;
		bool inside = false;

		foreach (string str in Names) {
			if (inside) {
				if (str == Name) {
					Values[i] = Value;
					break;
				}
			} else {
				if (Types[i] == TYPE_HEADER) {
					inside = (str == "[" + Header + "]");
				}
			}
			i++;
		}
	}

}


public class PlankConf : Window {
	private Scale IconSizeSlider;
	private Label IconSizeLabel;
	private INI ConfFile;
	private string ConfFileName;
	private const string ConfFileNameSuffix = "/.config/plank/dock1/settings";
	private Image TestIcon;
	private SList<string> Themes;
	private int ThemeNumber;
	private ComboBoxText ThemesBox;

	private void FindThemes() {
		Themes = new SList<string> ();
		string ThemesDirPath = "/usr/share/plank/themes";
		string CurrentThemeName = ConfFile.getByNameAndHeader("Theme", "PlankDockPreferences");
		int i = 0;

		try {
			GLib.Dir ThemesDir = GLib.Dir.open(ThemesDirPath, 0);
			while ((name = ThemesDir.read_name()) != null) {
				Themes.append(name);
			}
		} catch (FileError e) {
			GLib.stderr.printf("Error! Message: %s", e.message);
		}

		Themes.sort(strcmp);

		foreach (string Theme in Themes) {
			if (Theme == CurrentThemeName) {
				ThemeNumber = i;
			} else {
				i++;
			}
		}
	}

	private void destroyer() {
		Gtk.main_quit();
	}

	public PlankConf() {
		loadConfFile();

		int[] SizesMarks = {32,48, 64, 128};
		this.title = "Plank Simple Configurator";
		this.icon_name = "plank";
		this.window_position = WindowPosition.CENTER;
		this.destroy.connect(this.destroyer);
		set_default_size(500, 205);

		IconSizeLabel = new Label("Size of icons:");
		IconSizeSlider = new Scale.with_range(Orientation.HORIZONTAL, 32, 128, 2);
		int iconsize;
		iconsize = int.parse(ConfFile.getByNameAndHeader("IconSize", "PlankDockPreferences"));
		IconSizeSlider.set_value(iconsize);
		foreach (int i in SizesMarks) {
			IconSizeSlider.add_mark(i, PositionType.BOTTOM, i.to_string());
		}
		IconSizeSlider.adjustment.value_changed.connect (() => {
			TestIcon.pixel_size = (int) IconSizeSlider.get_value();
			saveConfFile();
		});

		TestIcon = new Image.from_icon_name ("plank", IconSize.LARGE_TOOLBAR);
		TestIcon.set_size_request(135, 135);
		TestIcon.pixel_size = iconsize;

		FindThemes();
		ThemesBox = new ComboBoxText();
		foreach (string str in Themes) {
			ThemesBox.append_text(str);
		}
		ThemesBox.active = ThemeNumber;
		ThemesBox.changed.connect (saveConfFile);

		Label ThemesLabel = new Label("Theme:");

		var vbox = new Box(Orientation.VERTICAL, 0);
		var hbox = new Box(Orientation.HORIZONTAL, 0);
		hbox.pack_start(IconSizeLabel, false, false, 3);
		hbox.pack_start(IconSizeSlider, true, true, 3);
		hbox.pack_end(TestIcon, false, false, 0);
		vbox.pack_start(hbox, true, true, 0);
		var hbox2 = new Box(Orientation.HORIZONTAL, 0);
		hbox2.pack_start(ThemesLabel, false, false, 3);
		hbox2.pack_end(ThemesBox, true, true, 0);
		vbox.pack_end(hbox2, true, true, 0);
		add(vbox);
	}

	private void loadConfFile() {
		ConfFile = new INI();
		ConfFileName = Environment.get_home_dir() + ConfFileNameSuffix;
		stdout.printf(Environment.get_home_dir());
		ConfFile.load(ConfFileName);
	}

	private void saveConfFile() {
		ConfFile.setByNameAndHeader("IconSize", "PlankDockPreferences", IconSizeSlider.get_value().to_string());
		ConfFile.setByNameAndHeader("Theme", "PlankDockPreferences", ThemesBox.get_active_text());
		ConfFile.save(ConfFileName);
	}


	public static int main(string[] args) {
		Gtk.init(ref args);

		var window = new PlankConf();
		window.show_all();

		Gtk.main();
		return 0;
	}
}
