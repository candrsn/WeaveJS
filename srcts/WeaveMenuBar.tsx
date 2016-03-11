import * as React from "react";
import MenuBar from "./react-ui/MenuBar";
import * as FileSaver from "filesaver.js";
import FileInput from "./react-ui/FileInput";
import PopupWindow from "./react-ui/PopupWindow";
import {HBox, VBox} from "./react-ui/FlexBox";
import FileMenu from "./menus/FileMenu";
import DataMenu from './menus/DataMenu';

export interface WeaveMenuBarProps extends React.Props<WeaveMenuBar> {
	weave:Weave
}

export interface WeaveMenuBarState {
	
}

function weaveMenu(weave:Weave)
{
    return {
		label: "Weave",
		bold: true,
		menu: [
			{
				label: "Preferences...",
				click: () => {}
			},
			{
				label: "Edit Session State",
				click: () => {},
				menu: [
					{
						label: "Nested",
						click: () => { console.log("I'm a child") }
					}
				]
			},
			{
			},
			{
				label: "Report a problem",
				click: () => {},
				enabled: false
			},
			{
				label: "Visit iWeave.com",
				click: () => {}
			},
			{
				label: "Visit Weave Wiki",
				click: () => {}
			},
			{
			},
			{
				label: "Version: 2.0",
				click: () => {}
			}, 
			{
			},
			{
				label: "Restart",
				click: () => {}
			}
		]
	};
}

/*function dataMenu(weave:Weave)
{
	return {
		label: "Data",
		menu: [
			{
				label: "Manage or browse data",
				click: () => { console.log("Manage or browse data") }
			},
			{
			},
			{
				label: "Add CSV DataSource",
				click: () => { console.log("Add CSV DataSource") }
			}
		]
	};
}*/

export default class WeaveMenuBar extends React.Component<WeaveMenuBarProps, WeaveMenuBarState>
{
	fileMenu:FileMenu;
	dataMenu:DataMenu;
	constructor(props:WeaveMenuBarProps)
	{
		super(props);
		this.fileMenu = new FileMenu(props.weave);
		this.dataMenu = new DataMenu(props.weave);
	}
	
	render():JSX.Element
	{
        var weave = this.props.weave;
		return (
			<MenuBar config={[weaveMenu(weave), this.fileMenu, this.dataMenu]}/>
		);
	}
}
