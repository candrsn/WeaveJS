/// <reference path="../../typings/react/react.d.ts"/>
/// <reference path="../../typings/react-bootstrap/react-bootstrap.d.ts"/>
/// <reference path="../../typings/react-swf/react-swf.d.ts"/>
/// <reference path="../../typings/lodash/lodash.d.ts"/>

import * as React from "react";
import * as ReactDOM from "react-dom";
import * as bs from "react-bootstrap";
import * as _ from "lodash";
import VBox from "./VBox";
import HBox from "./HBox";

export type CheckBoxOption = {
	value:any, 
	label:string
}

export interface ICheckBoxListProps extends React.Props<CheckBoxList>
{
    options:CheckBoxOption[];
    labels?:string[];
    onChange?:(selectedValues:string[]) => void;
    selectedValues?:string[];
    labelPosition?:string;
}

export interface ICheckBoxListState
{
    checkboxStates:boolean[];
}

export default class CheckBoxList extends React.Component<ICheckBoxListProps, ICheckBoxListState>
{
    private checkboxes:HTMLElement[];
	
	private values:any[] = [];
	private labels:string[] = [];

    constructor(props:ICheckBoxListProps)
	{
        super(props);

        if (this.props.selectedValues)
        {
            this.state = {
                checkboxStates: props.options.map((option) => {
                    return props.selectedValues.indexOf(option.value) >= 0;
                })
            }
        }
        else
        {
            this.state = {
                checkboxStates: props.options.map(() => {
                    return false;
                })
            }
        }
    }

    componentWillReceiveProps(nextProps:ICheckBoxListProps)
	{
		this.values = _.pluck(this.props.options, "value");
		this.labels = _.pluck(this.props.options, "label");
		
        if (nextProps.selectedValues)
        {
            var checkboxStates:boolean[] = nextProps.options.map((option) => {
                return nextProps.selectedValues.indexOf(option.value) > -1;
            });

            this.setState({
                checkboxStates
            });
        }
    }

    handleChange(index:number, event:React.FormEvent)
	{
        var checkboxState:boolean = (event.target as any).checked;
        var checkboxStates:boolean[] = this.state.checkboxStates.splice(0);
        checkboxStates[index] = checkboxState;

        var selectedValues:string[] = [];
        checkboxStates.forEach((checkboxState:boolean, index:number) => {
            if (checkboxState)
            {
                selectedValues.push(this.props.options[index].value);
            }
        });

        if (this.props.onChange)
            this.props.onChange(selectedValues);

        this.setState({
            checkboxStates
        });
    }

    render():JSX.Element
	{
        var labelPosition:string = this.props.labelPosition || "right";

        return (
            <div style={{height: "100%", width: "100%", overflow: "scroll"}}>
                {
                    this.state.checkboxStates.map((checkBoxState:boolean, index:number) => {
                        var checkboxItem:JSX.Element[] = [
                            <input key="input" type="checkbox" checked={checkBoxState} value={this.values[index]} onChange={this.handleChange.bind(this, index)}/>,
                            <span key="span" style={{paddingLeft: 5}}>
								{ this.labels[index] }
							</span>
                        ];
                        return (
                            <HBox key={index} style={{height: 30, paddingLeft: 10}}>
                                {
                                    labelPosition == "right" ? checkboxItem : checkboxItem.reverse()
                                }
                            </HBox>
                        );
                    })
                }
            </div>
        );
    }
}
