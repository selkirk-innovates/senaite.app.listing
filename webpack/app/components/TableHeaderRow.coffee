import React from "react"

import Checkbox from "./Checkbox.coffee"
import TableHeaderCell from "./TableHeaderCell.coffee"


class TableHeaderRow extends React.Component
  ###
   * The table header row component renders a single row with cells
  ###

  constructor: (props) ->
    super(props)
    @on_header_column_click = @on_header_column_click.bind @

  on_header_column_click: (event) ->
    ###
     * Event handler when a header columns was clicked
    ###
    el = event.currentTarget

    index = el.getAttribute "index"
    sort_order = el.getAttribute "sort_order"

    if not index
      return

    console.debug "HEADER CLICKED sort_on='#{index}' sort_order=#{sort_order}"

    # toggle the sort order if the clicked column was the active one
    if "active" in el.classList
      if sort_order == "ascending"
        sort_order = "descending"
      else
        sort_order = "ascending"

    # call the parent event handler with the sort index and the sort order
    @props.on_header_column_click index, sort_order

  is_required_column: (key) ->
    ###
     * Check if the column is required
    ###

    # XXX This is a workaround for a missing key within the column definition
    folderitems = @props.folderitems or []
    if folderitems.length == 0
      return no
    first_item = folderitems[0]
    required = first_item.required or []
    return key in required

  is_sortable: (column, key) ->
    ###
     * Check if the column is sortable
    ###
    if column.sortable is no
      return no
    if column.index
      return yes
    if key in @props.sortable_columns
      return yes
    return no

  build_cells: ->
    ###
     * Build all cells for the row
    ###

    cells = []

    item = @props.item
    checkbox_name = "select_all"
    checkbox_value = "all"

    # insert select column
    if @props.show_select_column

      show_select_all_checkbox = @props.show_select_all_checkbox

      cells.push(
        <th className="select-column" key="select_all">
          {show_select_all_checkbox and
            <Checkbox
              name={checkbox_name}
              value={checkbox_value}
              checked={@props.all_selected}
              onChange={@props.on_select_checkbox_checked}/>}
        </th>
      )

    # insert row dnd column
    if @props.allow_row_reorder
      cells.push(
        <th className="dnd-column" key="dnd">
        </th>
      )

    # insert table columns in the right order
    for key in @props.visible_columns

      # get the column object
      column = @props.columns[key]
      # check if the key is in the sortable columns
      sortable = @is_sortable column, key
      # sort index
      index = column.index or key

      title = column.title
      alt = column.alt or title
      # sort_on is the current sort index/metadata
      sort_on = @props.sort_on or "created"
      sort_order = @props.sort_order or "ascending"
      # check if the current sort_on is the index of this column
      is_sort_column = index is sort_on
      # check if the column is required
      required = @is_required_column key

      cls = [key]
      if sortable
        cls.push "sortable"
      if is_sort_column and sortable
        cls.push "active #{sort_order}"
      if required
        cls.push "required"
      cls = cls.join " "

      cells.push(
        <TableHeaderCell
          key={key}  # internal key
          {...@props}  # pass in all properties from the table component
          title={title}
          alt={alt}
          index={index}
          sort_order={sort_order}
          className={cls}
          onClick={if sortable then @on_header_column_click else undefined}
          />
      )

    return cells

  render: ->
    <tr onContextMenu={@props.on_context_menu}>
      {@build_cells()}
    </tr>


export default TableHeaderRow
