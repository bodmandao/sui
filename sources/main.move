module dacade_deepbook::book {
    use std::vector;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{transfer, share_object};

    // struct
    struct Event has key, store{
        id: UID,
        name: String,
        date: String,
        location: String,
        budget: u64,
        tasks: vector<Task>,
        participants: vector<Participant>,
        finished: bool,
    }

    struct Task has key, store{
        id: UID,
        name: String,
        assigned_to: UID,
        completed: bool,
    }

    struct Participant has key, store{
        id: UID,
        name: String,
        addr: address,
        balance: Balance<SUI>,
    }

    struct EventPlanner has key, store {
        id: UID,
        events: vector<Event>,
    }


    fun init(ctx: &mut TxContext) {
        let planner = EventPlanner {
            id: object::new(ctx),
            events: vector::empty<Event>(),
        };
        share_object(planner);
    }

    fun get_events(planner :&mut EventPlanner) : &mut vector<Event> {
        // let planner: EventPlanner = get_planner(); 
        return &mut planner.events
    }

    // fun get_planner() : EventPlanner {
    //     return object::get::<EventPlanner>(object::all::<EventPlanner>()[0]);
    // }

    public fun add_event(planner : &mut EventPlanner, name: String, date: String, location: String, budget: u64, ctx: &mut TxContext) {
        let events = get_events(planner);
        let new_event_id = object::new(ctx);
        let new_event = Event {
            id: new_event_id,
            name,
            date,
            location,
            budget,
            tasks: vector::empty<Task>(),
            participants: vector::empty<Participant>(),
            finished: false,
        };
        vector::push_back(events, new_event);
    }

    public fun add_task(planner : &mut EventPlanner,event_index: u64, name: String, assigned_to: UID, ctx: &mut TxContext) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let new_task_id = object::new(ctx);
        let new_task = Task {
            id: new_task_id,
            name,
            assigned_to,
            completed: false,
        };
        vector::push_back(&mut event.tasks, new_task);
    }

    public fun add_participant(planner : &mut EventPlanner,event_index: u64, name: String, ctx: &mut TxContext) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let new_participant_id = object::new(ctx);
        let new_participant = Participant {
            id: new_participant_id,
            name,
            addr: sui::tx_context::sender(ctx),
            balance: balance::zero(),
        };
        vector::push_back(&mut event.participants, new_participant);
    }

    public fun complete_task(planner : &mut EventPlanner,event_index: u64, task_index: u64) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let task = vector::borrow_mut(&mut event.tasks, task_index);
        task.completed = true;
    }

    public fun finish_event(planner : &mut EventPlanner,event_index: u64) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        event.finished = true;
    }

    public fun get_event(planner: &mut EventPlanner, event_index: u64): &mut Event {
        let events = get_events(planner);
        return vector::borrow_mut(events, event_index)
    }

    public fun update_participant_balance(planner: &mut EventPlanner, event_index: u64, participant_index: u64, new_balance: Balance<SUI>, ctx: &mut TxContext) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let participant = vector::borrow_mut(&mut event.participants, participant_index);
        participant.balance = new_balance;
    }

    public fun filter_events(planner: &mut EventPlanner, filter: fn(&Event) -> bool): vector<Event> {
        let events = get_events(planner);
        let mut filtered_events: vector<Event> = vector::empty();
        for event in events.iter() {
            if filter(event) {
                vector::push_back(&mut filtered_events, event.clone());
            }
        }
        return filtered_events;
    }

    public fun search_events(planner: &mut EventPlanner, search_term: String): vector<Event> {
        let events = get_events(planner);
        let search_results: vector<Event> = vector::empty();
        for (event in events.iter()) {
            if event.name.contains(&search_term) || event.location.contains(&search_term) {
            vector::push_back(&mut search_results, event.clone());
            }
        }
        return search_results;
    }

    public fun update_event(planner: &mut EventPlanner, event_index: u64, name: Option<String>, date: Option<String>, location: Option<String>, budget: Option<u64>, ctx: &mut TxContext) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);

        if (Some(new_name) = name) {
            event.name = new_name;
        };
        if (Some(new_date) = date) {
            event.date = new_date;
        };
        if (Some(new_location) = location) {
            event.location = new_location;
        };
        if (Some(new_budget) = budget) {
            event.budget = new_budget;
        }
    }

}
