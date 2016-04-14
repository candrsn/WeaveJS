import * as React from "react";
import * as _ from "lodash";
import StatefulTextField from "../ui/StatefulTextField";
import Checkbox from "../semantic-ui/Checkbox";
import {linkReactStateRef} from "../utils/WeaveReactUtils";
import ReactUtils from "../utils/ReactUtils";
import WeaveTree from "../ui/WeaveTree";
import {HBox, VBox} from "../react-ui/FlexBox";
import DataSourceEditor from "./DataSourceEditor";
import {IDataSourceEditorProps, IDataSourceEditorState} from "./DataSourceEditor";
import CKANDataSource = weavejs.data.source.CKANDataSource;
import EntityNode = weavejs.data.hierarchy.EntityNode;
import EntityType = weavejs.api.data.EntityType;
import IWeaveTreeNode = weavejs.api.data.IWeaveTreeNode;
import URLRequestUtils = weavejs.api.data.IWeaveTreeNode;
import ColumnUtils = weavejs.data.ColumnUtils;
import IQualifiedKey = weavejs.api.data.IQualifiedKey;
import ColumnTreeNode = weavejs.data.hierarchy.ColumnTreeNode;

export default class CKANDataSourceEditor extends DataSourceEditor
{
	private _dataSourceNode:ColumnTreeNode
	constructor(props:IDataSourceEditorProps)
	{
		super(props);
	}
	
	get editorFields():[React.ReactChild, React.ReactChild][]
	{
		let ds = (this.props.dataSource as CKANDataSource);
		var labelStyle:React.CSSProperties = {
			marginRight: 20,
			display: "flex",
			fontWeight: "normal"
		};
		
		var checkBoxStyle:React.CSSProperties = {
			marginRight: 8
		};
		
		var hBoxStyle:React.CSSProperties = {
			alignItems: "center"
		}

		let editorFields:[React.ReactChild, React.ReactChild][] = [
			[
				Weave.lang("Source URL *"), 
				<StatefulTextField selectOnFocus={true} style={{width: "100%"}} ref={linkReactStateRef(this, { value: ds.url})}/>
			],
			[
				Weave.lang("Items to show in hierarchy"),
				<HBox style={hBoxStyle}>
					<label style={labelStyle}><Checkbox style={checkBoxStyle} ref={linkReactStateRef(this, {value: ds.showPackages})}/>{Weave.lang("Packages")}</label>
					<label style={labelStyle}><Checkbox style={checkBoxStyle} ref={linkReactStateRef(this, {value: ds.showGroups})}/>{Weave.lang("Groups")}</label>
					<label style={labelStyle}><Checkbox style={checkBoxStyle} ref={linkReactStateRef(this, {value: ds.showTags})}/>{Weave.lang("Tags")}</label>
				</HBox>
			],
			[
				Weave.lang("API Version"),
				<HBox style={hBoxStyle}>
					<HBox style={labelStyle}><StatefulTextField ref={linkReactStateRef(this, {value: ds.apiVersion})} type="number" min="1" max="3" step="1"/></HBox>
					<HBox style={labelStyle}><Checkbox style={checkBoxStyle} ref={linkReactStateRef(this, { value: ds.useHttpPost})}/><span>{Weave.lang("Use HTTP POST")}</span></HBox>
				</HBox>
			],
			[
				<span/>,
				<HBox style={hBoxStyle}><Checkbox style={checkBoxStyle} ref={linkReactStateRef(this, { value: ds.useDataStore})}/><span>{Weave.lang("Use Data Store if available")}</span></HBox>
			]
		];
		return super.editorFields.concat(editorFields);
	}
}
