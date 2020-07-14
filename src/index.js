import { Elm } from './Main.elm';
import 'babel-polyfill'
import './main.ts';

Elm.Main.init({
    node: document.querySelector('main')
});
