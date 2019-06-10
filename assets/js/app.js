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

class HelloReact extends React.Component {
  render() {
    return (<h1>Hello React!</h1>)
  }
}

//ReactDOM.render( 
  //<HelloReact />,
  //document.getElementById("hello-react")
//)
//

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
        <li>{title}<FileList items={children} /></li>
      );
    }
  }
}
class FileList extends React.Component {
  render() {
    
    const items = [];
    this.props.items.forEach((item) => {
      items.push(
        <ListItem item={item} key={item.path} />
      );
    });


    return (
      <ul>
      {items}
      </ul>
    );
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
      console.log("Loaded items: ", this.state.items);
    })
  }

  render() {
    return(<FileList items={this.state.items} />);
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





