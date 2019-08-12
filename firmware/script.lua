-- Wash Firmware

setup = function()
    -- global variables
    balance = 0.0
    balance_seconds = 0
        
    -- constants
    welcome_mode_seconds = 3
    thanks_mode_seconds = 20
    free_pause_seconds = 120
    
    price_pause = 20;
    price_water = 20;
    price_soap = 25;
    price_active_soap = 36;
    price_vacuum = 10;
    price_wax = 20;
    
    mode_welcome = 0
    mode_ask_for_money = 10
    mode_start = 20
    mode_water = 30
    mode_soap = 40
    mode_active_soap = 50
    mode_pause = 60
    mode_vacuum = 70
    mode_wax = 80
    mode_thanks = 90
    
    currentMode = mode_welcome
    version = "0.1"

    printMessage("Kanatnikoff Wash v." .. version)
    return 0
end

-- loop is being executed
loop = function()
    currentMode = run_mode(currentMode)
    smart_delay(100)
    return 0
end

run_mode = function(new_mode)
    if new_mode == mode_welcome then return welcome_mode() end
    if new_mode == mode_ask_for_money then return ask_for_money_mode() end
    if new_mode == mode_start then return start_mode() end
    if new_mode == mode_water then return water_mode() end
    if new_mode == mode_soap then return soap_mode() end
    
    if new_mode == mode_active_soap then return active_soap_mode() end
    if new_mode == mode_pause then return pause_mode() end
    if new_mode == mode_vacuum then return vacuum_mode() end
    if new_mode == mode_wax then return wax_mode() end
    if new_mode == mode_thanks then return thanks_mode() end
end

welcome_mode = function()
    show_welcome()
    run_stop()
    turn_light(0, animation.idle)
    smart_delay(1000 * welcome_mode_seconds)
    return mode_ask_for_money
end

ask_for_money_mode = function()
    show_ask_for_money()
    run_stop()
    turn_light(0, animation.idle)
    update_balance();
    if balance > 0.9 then
        return mode_start
    end
    return mode_ask_for_money
end

start_mode = function()
    show_start(balance)
    run_pause()
    turn_light(0, animation.intense)
    balance_seconds = free_pause_seconds    
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    -- user has no reason to start with pause here
    if suggested_mode >= 0 and suggested_mode~=mode_pause then return suggested_mode end
    return mode_start
end

water_mode = function()
    show_water(balance)
    run_water()
    turn_light(1, animation.one_button)
    charge_balance(price_water)
    if balance <= 0.01 then return mode_thanks end
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_water
end

soap_mode = function()
    show_soap(balance)
    run_soap()
    turn_light(2, animation.one_button)
    charge_balance(price_soap)
    if balance <= 0.01 then return mode_thanks end
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_soap
end

active_soap_mode = function()
    show_active_soap(balance)
    run_active_soap()
    turn_light(3, animation.one_button)
    charge_balance(price_active_soap)
    if balance <= 0.01 then return mode_thanks end
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_active_soap
end

pause_mode = function()
    show_pause(balance, balance_seconds)
    run_pause()
    turn_light(6, animation.one_button)
    update_balance()
    if balance_seconds > 0 then
        balance_seconds = balance_seconds - 0.1
    else
        balance_seconds = 0
        charge_balance(price_pause)         
    end
    
    if balance <= 0.01 then return mode_thanks end
    
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_pause
end

vacuum_mode = function()
    show_vacuum(balance)
    run_vacuum()
    turn_light(5, animation.one_button)
    charge_balance(price_vacuum)
    if balance <= 0.01 then return mode_thanks end
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_vacuum
end

wax_mode = function()
    show_wax(balance)
    run_wax()
    turn_light(4, animation.one_button)
    charge_balance(price_wax)
    if balance <= 0.01 then return mode_thanks end
    update_balance()
    suggested_mode = get_mode_by_pressed_key()
    if suggested_mode >=0 then return suggested_mode end
    return mode_wax
end

thanks_mode = function()
    balance = 0
    show_thanks()
    turn_light(1, animation.idle)
    run_program(program.pause)
    waiting_loops = thanks_mode_seconds * 10;
    
    while(waiting_loops>0)
    do
        update_balance()
        if balance > 0.99 then return mode_start end
        smart_delay(100)
        waiting_loops = waiting_loops - 1
    end

    return mode_ask_for_money
end


show_welcome = function()
    welcome:Display()
end

show_ask_for_money = function()
    ask_for_money:Display()
end

show_start = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    start:Set("balance.value", balance_int)
    start:Display()
end

show_water = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    water:Set("balance.value", balance_int)
    water:Display()
end

show_soap = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    soap:Set("balance.value", balance_int)
    soap:Display()
end

show_active_soap = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    active_soap:Set("balance.value", balance_int)
    active_soap:Display()
end

show_pause = function(balance_rur, balance_sec)
    balance_int = math.ceil(balance_rur)
    sec_int = math.ceil(balance_sec)
    pause:Set("pause_balance.value", sec_int)
    pause:Set("balance.value", balance_int)
    pause:Display()
end

show_vacuum = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    vacuum:Set("balance.value", balance_int)
    vacuum:Display()
end

show_wax = function(balance_rur)
    balance_int = math.ceil(balance_rur)
    wax:Set("balance.value", balance_int)
    wax:Display()
end

show_thanks =  function() 
    thanks:Display()
end

get_mode_by_pressed_key = function()
    pressed_key = get_key()
    if pressed_key == 1 then return mode_water end
    if pressed_key == 2 then return mode_soap end
    if pressed_key == 3 then return mode_active_soap end
    if pressed_key == 4 then return mode_wax end
    if pressed_key == 5 then return mode_vacuum end
    if pressed_key == 6 then return mode_pause end
    return -1
end

get_key = function()
    return hardware:GetKey()
end

smart_delay = function(ms)
    hardware:SmartDelay(ms)
end

turn_light = function(rel_num, animation_code)
    hardware:TurnLight(rel_num, animation_code)
end

run_pause = function()
    run_program(program.pause)
end

run_water = function()
    run_program(program.water)
end

run_soap = function()
    run_program(program.soap)
end

run_active_soap = function()
    run_program(program.active_soap)
end

run_vacuum = function()
    run_program(program.vacuum)
end

run_wax = function()
    run_program(program.wax)
end

run_stop = function()
    run_program(program.stop)
end

run_program = function(program_num)
    hardware:TurnProgram(program_num)
end

update_balance = function()
    balance = balance + hardware:GetCoins()
    balance = balance + hardware:GetBanknotes()
end

charge_balance = function(price)
    balance = balance - price * 0.001666666667
    if balance<0 then balance = 0 end
end
