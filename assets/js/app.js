// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import React from "react"
import ReactDOM from "react-dom"

/********************************************************************************
 *                                                                              *
 * File list                                                                    *
 *                                                                              *
 *******************************************************************************/

class ListItem extends React.Component {
  render() {
    const title = this.props.item.title;
    const children = this.props.item.children;
    const path = '/file/' + this.props.item.path;

    if(children.length == 0) {
      return (
        <li><a href={path}>{title}</a></li>
      );
    }
    else {
      return(
        <li>{title}<FileList items={children} basePath={this.props.item.path} /></li>
      );
    }
  }
}
class FileList extends React.Component {

	addNew(event) {
		event.stopPropagation();
		let fileName = window.prompt("Bestandsnaam", "*.md");

		if(! fileName) {
			return;
		}
		// Default to md files.
		if(! fileName.match(/\.[^\.]+$/)) {
			fileName = fileName + '.md';
		}

		let url = this.props.basePath + '/' + fileName;
		let title = fileName.replace(/\.[^\.]+$/, '');       console.log(this.props);
		console.log("Creating file ", url );

		fetch('/file?path=' + url, {
			method: 'post',
			headers: {'Content-Type':'application/json'},
		})
    .then(function(response) {
      if (!response.ok) {
        throw Error(response.statusText);
      }
      location.href = "/file/" + url;
    })
    .catch(function(error) {
      alert("Bestandsnaam ongeldig.");
    });
	
	}

  render() {

    const items = [];
    this.props.items.forEach((item) => {
      items.push(
        <ListItem item={item} key={item.path} />
      );
    });

    if(items.length > 10) {
    return (
      <ul>
      <li><button onClick={(e) => this.addNew(e)}>+</button></li>
      {items}
      <li><button onClick={(e) => this.addNew(e)}>+</button></li>

      </ul>
    )
    } else {
      return (
        <ul>
        {items}
        <li><button onClick={(e) => this.addNew(e)}>+</button></li>

        </ul>
      );
    }
  }
}


class FileListLoader extends React.Component {
  constructor() {
    super();
    this.state = {
      items: []
    }
  }

  componentDidMount() {
    fetch("/api/file/")
    .then(results =>  {
      return results.json();
    })
    .then(data => {
      this.setState({items: data});
      //console.log("Loaded items: ", this.state.items);
    })
  }

  render() {
    return(<FileList items={this.state.items} basePath="" />);
  }
}

ReactDOM.render(
  <FileListLoader />,
  document.getElementById("file-list")
)
//ReactDOM.render(
  //<FileList />,
  //document.getElementById("file-list")
//)





