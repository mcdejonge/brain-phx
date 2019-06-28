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

/********************************************************************************
 *                                                                              *
 * File editor                                                                  *
 *                                                                              *
 *******************************************************************************/
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faEdit} from '@fortawesome/free-solid-svg-icons'
import { faCheckCircle} from '@fortawesome/free-solid-svg-icons'

class Editor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      url: null,
      data : {}
    }
    this.closeEditor = this.closeEditor.bind(this);
    this.handleChange = this.handleChange.bind(this);
  }

  closeEditor(event) {
    event.stopPropagation();
    event.preventDefault();
    fetch(this.props.url, {
      method: 'put',
      headers: {
        'Content-Type' : 'application/json',
        'Accept' : 'application/json',
      },
      body: JSON.stringify({'contents' : this.state.contents})
    })
    .then(function(response) {
      document.getElementById('editor-wrapper').style.display = "none";
      if (!response.ok) {
        throw Error(response.statusText);
      }
    })
    .catch(function(error) {
      alert('Bestand kon niet worden opgeslagen.');
    })
  }

  handleChange(event) {
    this.setState({contents: event.target.value});
  }
  componentDidMount() {
    fetch(this.props.url, {
      method: 'get',
      headers: {'Accept' : 'application/json'},
    })
    .then(function(response) {
      if(!response.ok) {
        throw Error(response.statusText);
      }
      return response.json();
    })
    .then(data => {
      this.setState({
        url : this.props.url,
        data : data,
        contents : data.contents

      });
    })
    .catch(function(error) {
      alert('Ongeldig bestand.');
    })
  }

  render() {
    document.getElementById('editor-wrapper').style.display = "block";
    return(
      <div id="editor-inner">
        <form onSubmit={this.closeEditor}>
          <textarea name="editor-content" value={this.state.contents} onChange={this.handleChange} />
          <button onClick={this.closeEditor}><FontAwesomeIcon icon={faCheckCircle} /></button>
        </form>
      </div>
    )
  }

}
class ActivateEditorButton extends React.Component {

  constructor(props) {
    super(props);
    this.openEditor = this.openEditor.bind(this);
    this.state = {
      url : location.href.replace(/https*:\/\/.*?\//, '/api/')

    }
  }

  openEditor(event) {
    event.stopPropagation();
    if(this.state.editorOpen) {
      return;
    }

    ReactDOM.render(<Editor url={this.state.url} />, document.getElementById('editor-wrapper'));

  }

  render() {
    return(<button onClick={this.openEditor}><FontAwesomeIcon icon={faEdit} /></button>);
  }
}
ReactDOM.render(
  <ActivateEditorButton />,
  document.getElementById("edit-button-top")
)
ReactDOM.render(
  <ActivateEditorButton />,
  document.getElementById("edit-button-bottom")
)


