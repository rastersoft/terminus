
const Main = imports.ui.main;
const Shell = imports.gi.Shell;
const Meta = imports.gi.Meta;
const Gio = imports.gi.Gio;
const Lang = imports.lang;
const ExtensionUtils = imports.misc.extensionUtils;

const MyIface = '<node>\
<interface name="com.rastersoft.terminus">\
  <method name="SwapGuake" />\
  <method name="DisableKeybind" />\
  <method name="DoPing" >\
    <arg name="n" direction="in" type="i"/>\
    <arg name="response" direction="out" type="i"/>\
  </method>\
</interface>\
</node>';

const MyProxy = Gio.DBusProxy.makeProxyWrapper(MyIface);
const GioSSS = Gio.SettingsSchemaSource;

const TerminusClass = new Lang.Class({
   Name: 'Terminus.Launcher',

	_init: function() {

		this._settings = new Gio.Settings({schema: 'org.rastersoft.terminus.keybindings'});
		this._settingsChanged(null,"guake-mode"); // copy the guake-mode key to guake-mode-gnome-shell key
		this._settingsChangedConnect = this._settings.connect('changed',Lang.bind(this,this._settingsChanged));

	   let mode = Shell.ActionMode ? Shell.ActionMode.NORMAL : Shell.KeyBindingMode.ALL;
	   let flags = Meta.KeyBindingFlags.NONE;
	   this.instance = null;
	   Main.wm.addKeybinding("guake-mode-gnome-shell",
		   this._settings,
		   flags,
		   mode,
			Lang.bind(this, this.launch_function)
	   );
	},

	destroy: function() {
		Main.wm.removeKeybinding("guake-mode");
	},

	launch_function: function() {
		if (this.instance === null) {
			this.instance = new MyProxy(Gio.DBus.session, 'com.rastersoft.terminus','/com/rastersoft/terminus');
        }
		this.instance.DisableKeybindRemote(Lang.bind(this, function (result, error) {
            this.instance.SwapGuakeSync();
        }));
	},

	_settingsChanged: function(st,name) {
    	if (name == "guake-mode") {
			var new_key = this._settings.get_string("guake-mode");
			this._settings.set_strv("guake-mode-gnome-shell",new Array(new_key));
		}
	}
});


function init() {

}

let terminusObject;

function enable() {
	terminusObject = new TerminusClass();
}

function disable() {

}
