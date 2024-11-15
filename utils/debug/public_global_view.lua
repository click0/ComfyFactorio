local Gui = require 'utils.gui'
local Global = require 'utils.global'
local Color = require 'utils.color_presets'
local Model = require 'utils.debug.model'

local dump = Model.dump
local dump_text = Model.dump_text
local concat = table.concat

local Public = {}

local header_name = Gui.uid_name()
local left_panel_name = Gui.uid_name()
local right_panel_name = Gui.uid_name()
local input_text_box_name = Gui.uid_name()
local filter_text_box_name = Gui.uid_name()
local refresh_name = Gui.uid_name()

Public.name = 'Tokens'

function Public.show(container, filter)
    container.clear()
    local main_flow = container.add { type = 'flow', direction = 'horizontal' }

    local left_flow = main_flow.add({ type = 'flow', direction = 'vertical' })
    left_flow.style.width = 400

    local left_top_flow = left_flow.add { type = 'flow', direction = 'horizontal' }

    local filter_text_name = left_top_flow.add { type = 'text-box', name = filter_text_box_name, tooltip = 'Filter for tokens', text = filter or '' }

    if filter then
        filter_text_name.focus()
    end

    local left_panel = left_flow.add { type = 'scroll-pane', name = left_panel_name }
    local left_panel_style = left_panel.style
    left_panel_style.width = 400

    for token_id, token_name in pairs(Global.names) do
        if filter then
            if token_name:lower():find(filter:lower()) then
                local header = left_panel.add({ type = 'flow' }).add { type = 'label', name = header_name, caption = token_name }
                Gui.set_data(header, token_id)
            end
        else
            local header = left_panel.add({ type = 'flow' }).add { type = 'label', name = header_name, caption = token_name }
            Gui.set_data(header, token_id)
        end
    end

    local right_flow = main_flow.add { type = 'flow', direction = 'vertical' }
    right_flow.style.horizontally_stretchable = true

    local right_top_flow = right_flow.add { type = 'flow', direction = 'horizontal' }

    local input_text_box = right_top_flow.add { type = 'text-box', name = input_text_box_name }
    local input_text_box_style = input_text_box.style
    input_text_box_style.horizontally_stretchable = true
    input_text_box_style.height = 32
    input_text_box_style.maximal_width = 1000

    local refresh_button = right_top_flow.add { type = 'sprite-button', name = refresh_name, sprite = 'utility/reset', tooltip = 'Refresh' }
    local refresh_button_style = refresh_button.style
    refresh_button_style.width = 32
    refresh_button_style.height = 32

    local right_panel = right_flow.add { type = 'text-box', name = right_panel_name }
    right_panel.read_only = true
    right_panel.selectable = true

    local right_panel_style = right_panel.style
    right_panel_style.vertically_stretchable = true
    right_panel_style.horizontally_stretchable = true
    right_panel_style.maximal_width = 1000
    right_panel_style.maximal_height = 1000

    local data = {
        right_panel = right_panel,
        input_text_box = input_text_box,
        selected_header = nil
    }

    Gui.set_data(input_text_box, data)
    Gui.set_data(left_panel, data)
    Gui.set_data(refresh_button, data)
end

Gui.on_click(
    header_name,
    function (event)
        local element = event.element
        local token_id = Gui.get_data(element)

        local left_panel = element.parent.parent
        local data = Gui.get_data(left_panel)
        if not data then
            return
        end

        local right_panel = data.right_panel
        local selected_header = data.selected_header
        local input_text_box = data.input_text_box

        if selected_header then
            selected_header.style.font_color = Color.white
        end

        element.style.font_color = Color.orange
        data.selected_header = element

        input_text_box.text = concat { 'storage.tokens.', token_id }
        input_text_box.style.font_color = Color.black

        local id = Global.get_global(token_id)
        local content = dump(id) or 'Could not load data.'
        -- if content:find('function_handlers') then
        --     content = '{}' -- desync handler
        -- end
        right_panel.text = content
    end
)

local function update_dump(text_input, data)
    local suc, ouput = dump_text(text_input.text)
    if not suc then
        text_input.style.font_color = Color.red
    else
        text_input.style.font_color = Color.black
        data.right_panel.text = ouput
    end
end

Gui.on_text_changed(
    input_text_box_name,
    function (event)
        local element = event.element
        local data = Gui.get_data(element)

        update_dump(element, data)
    end
)

Gui.on_text_changed(
    filter_text_box_name,
    function (event)
        local element = event.element

        local text = element.text
        local parent = element.parent.parent.parent.parent

        Gui.remove_data_recursively(parent)
        Public.show(parent, text)
    end
)

Gui.on_click(
    refresh_name,
    function (event)
        local element = event.element
        local data = Gui.get_data(element)
        if not data then
            return
        end

        local input_text_box = data.input_text_box

        update_dump(input_text_box, data, event.player)
    end
)

return Public
