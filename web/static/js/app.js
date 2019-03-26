import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import "phoenix_html"
import { Socket } from 'phoenix';

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      comments: [],
      text: '',
    };
  }

  componentWillMount() {
    const socket = new Socket('/socket', { params: { token: window.userToken } });
    socket.connect();

    this.channel = socket.channel(`comments:${this.props.postId}`, {});
    this.channel.join()
      .receive('ok', ({ comments }) => {
        console.log(comments)
        this.setState({ comments })
      })
      .receive('error', resp => console.log('Unable to join', resp));

    this.channel.on(`comments:${this.props.postId}:new`, ({comment}) => {
      this.setState({ comments: this.state.comments.concat(comment) });
    });
  }

  onSubmit(event) {
    event.preventDefault();
    const { text } = this.state;
    this.channel.push('comments:add', { content: text });
    this.setState({ text: '' });
  }

  render() {
    const { comments } = this.state;

    return (
      <div>
        <form onSubmit={this.onSubmit.bind(this)}>
          <textarea
            value={this.state.text}
            onChange={e => this.setState({ text: e.target.value })}
          />
          <button>Submit</button>
        </form>

        <ul className="collection">
          {comments.map(comment =>
            <li key={comment.id} className="collection-item">
              {comment.content}
              <div className="right">
                {comment.user ? comment.user.nickname : 'Anonymous'}
              </div>
            </li>
          )}
        </ul>
      </div>
    );
  }
}

window.renderCommentsApp = (target, postId) => {
  ReactDOM.render(<App postId={postId} />, document.getElementById(target));
};
