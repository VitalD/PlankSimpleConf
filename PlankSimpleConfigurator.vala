using Gtk;
using Plank;

public class PlankConf : Window {
	private Scale IconSizeSlider;
	private Label IconSizeLabel;
	private string ConfFileName;
	private const string ConfFileNameSuffix = "/.config/plank/dock1/settings";
	private Image TestIcon;
	private SList<string> Themes;
	private int ThemeNumber;
	private ComboBoxText ThemesBox;
	private Plank.DockPreferences Preferences;
	private GLib.File ConfFile;

	private void FindThemes() {
		Themes = new SList<string> ();
		string ThemesDirPath = "/usr/share/plank/themes";
		string CurrentThemeName = Preferences.Theme;
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
		iconsize = Preferences.IconSize;
		IconSizeSlider.set_value(iconsize);
		foreach (int i in SizesMarks) {
			IconSizeSlider.add_mark(i, PositionType.BOTTOM, i.to_string());
		}
		IconSizeSlider.adjustment.value_changed.connect (() => {
			TestIcon.pixel_size = (int) IconSizeSlider.get_value();
			Preferences.IconSize = (int) IconSizeSlider.get_value();
			Preferences.apply();
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
		ThemesBox.changed.connect (() => {
			Preferences.Theme = ThemesBox.get_active_text();
			});

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
		ConfFileName = Environment.get_home_dir() + ConfFileNameSuffix;
		ConfFile = GLib.File.new_for_path(ConfFileName);
		Preferences = new Plank.DockPreferences.with_file(ConfFile);
	}

	public static int main(string[] args) {
		Gtk.init(ref args);

		var window = new PlankConf();
		window.show_all();

		Gtk.main();
		return 0;
	}
}
