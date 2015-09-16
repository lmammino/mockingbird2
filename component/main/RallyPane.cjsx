_ = require 'lodash'
React = require 'react'

RallyStore = require './RallyStore'

Alm = require './AlmApi'

queryUtils = require('rally').util.query

{Grid, Row, Col, Panel, TabbedArea, TabPane, Input, Table, Button} = require 'react-bootstrap'

RallyPane = React.createClass
  displayName: 'RallyPane'

  _setState: (data) ->
    @setState _.assign {}, @state, data

  componentDidMount: ->
    @_checkConnection()

  getInitialState: ->
    server: RallyStore.getServer()
    username: RallyStore.getUsername()
    password: RallyStore.getPassword()

  _onRallyServerDataChange: (e) ->
    data = {}
    attr = e.target.getAttribute('data-attribute')
    data[attr] = e.target.value
    RallyStore.setData data
    @_setState _.assign {}, data, connected: false, checkingConnection: true
    @_checkConnection()

  _checkConnection: ->
    Alm.api.query(
      type: 'user'
      fetch: [
        'DisplayName'
        'EmailAddress'
        'FirstName'
        'LastName'
        'LastPasswordUpdateDate'
        'Role'
        'SubscriptionAdmin'
        'SubscriptionID'
        'SubscriptionPermission'
        'TeamMemberships'
        'UserName'
        'UserPermissions'
        'UserProfile'
        'WorkspacePermission'
      ]
      query: queryUtils.where('Name', '=', @state.username)
    ).then((results) =>
      # @setData results.Results
      @_setState
        user: results.Results[0]
        connected: true
        checkingConnection: false
    ).fail (error) =>
      @_setState
        connected: false
        checkingConnection: false

  _renderUser: ->
    for field in ['UserName', 'EmailAddress', 'SubscriptionPermission', 'LastPasswordUpdateDate']
      <tr><td>{field}</td><td>{@state.user[field]}</td></tr>

  render: ->
    user = if @state.connected
      <div>
        <h3 style={{color: 'green'}} dangerouslySetInnerHTML={{__html: "&#10003; Connected!"}}></h3>
        <Table striped bordered condensed hover>
          {@_renderUser()}
        </Table>
      </div>
    else if @state.checkingConnection
      <div>
        <h3 style={{color: 'yellow'}} dangerouslySetInnerHTML={{__html: "Checking connection..."}}></h3>
      </div>
    else
      <div>
        <h3 style={{color: 'red'}} dangerouslySetInnerHTML={{__html: "&#10007; Not connected"}}></h3>
        <Button onClick={@_checkConnection}>Try Again</Button>
      </div>


    <form>
      <Input type="text" label='Server' value={@state.server} data-attribute="server" onChange={this._onRallyServerDataChange} />
      <Input type="text" label='Username' value={@state.username} data-attribute="username" onChange={this._onRallyServerDataChange} />
      <Input type="text" label='Password' value={@state.password} data-attribute="password" onChange={this._onRallyServerDataChange} />
      {user}
    </form>


module.exports = RallyPane