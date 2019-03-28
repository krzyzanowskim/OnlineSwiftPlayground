import React from "react";
import ReactDOM from "react-dom";
import uniqueId from 'react-html-id';
import $ from "jquery";

export default class SwiftVersion extends React.Component {
    constructor(props) {
        super(props);
        uniqueId.enableUniqueIds(this)

        this.availableVersions = ["5.0-RELEASE"]
        this.state = {
            currentVersion: this.availableVersions.slice(-1).pop()
        }
    }

    get currentVersion() {
        return this.state.currentVersion;
    }

    handleVersionClick(version) {
        this.setState((prevState) => ({
            currentVersion: version
        }))
    }

    render() {
        const VersionRows = () => {
            const Divider = () => {
                return <div className="dropdown-divider"/>
            }

            const VersionRow = (props) => {
                return <button type="button" className="btn btn-primary btn-sm rounded-0 dropdown-item" onClick={() => this.handleVersionClick(props.name)}>
                    {props.name}
                </button>;
            };

            return this.availableVersions.map(function(name, index) {
                return <VersionRow key={this.nextUniqueId()} name={name} />
            }, this)
        }

        return <div>
                <button type="button" className="btn btn-primary btn-sm rounded-0 dropdown-toggle" data-toggle="dropdown">
                    <span>{this.state.currentVersion}</span>
                </button>
                <div className="dropdown-menu rounded-0">
                    <VersionRows/>
                </div>
               </div>;
    }
}