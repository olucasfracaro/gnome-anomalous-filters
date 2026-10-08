import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

const DeuteranomalyEffect = GObject.registerClass(
class DeuteranomalyEffect extends Clutter.ShaderEffect {
    _init(shaderSource) {
        super._init();
        this._source = shaderSource;
        this.set_shader_source(this._source);
        this._strength = 0.5;
    }

    setStrength(strength) {
        this._strength = strength;
        this.queue_repaint();
    }

    vfunc_get_static_shader_source() {
        return this._source;
    }

    vfunc_paint_target(...args) {
        this.set_uniform_value('tex', 0);
        this.set_uniform_value('STRENGTH', parseFloat(this._strength));
        super.vfunc_paint_target(...args);
    }
});

export default class AnomalousFiltersExtension extends Extension {
    enable() {
        const shaderPath = this.dir.get_child('shaders').get_child('deuteranomaly.glsl').get_path();
        const [success, shaderSource] = GLib.file_get_contents(shaderPath);

        if (success) {
            const decoder = new TextDecoder('utf-8');
            this._effect = new DeuteranomalyEffect(decoder.decode(shaderSource));
            this._effect.setStrength(1.0);
            
            //aplica o efeito no container principal do GNOME Shell
            Main.uiGroup.add_effect_with_name('anomalous-deutan', this._effect);
        }
    }

    disable() {
        if (this._effect) {
            Main.uiGroup.remove_effect_by_name('anomalous-deutan');
            this._effect = null;
        }
    }
}
