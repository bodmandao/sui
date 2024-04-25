module dacade_deepbook::book {
    use std::vector;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer::{Self};
    use sui::table::{Self, Table};
    // ERRORS
    const ERROR_INVALID_CAP: u64 = 0;

    // struct
    struct Event has key, store {
        id: UID,
        name: String,
        date: String,
        location: String,
        budget: u64,
        tasks: Table<address, Task>,
        participants: Table<address, Participant>,
        finished: bool,
    }

    struct EventCap has key {
        id: UID,
        event_id: ID,
        owner: address
    }

    struct Task has key, store{
        id: UID,
        name: String,
        assigned_to: address,
        completed: bool,
    }

    struct Participant has key, store{
        id: UID,
        name: String,
        addr: address,
        balance: Balance<SUI>,
    }

    public fun new_event(name: String, date: String, location: String, budget: u64, ctx: &mut TxContext) {
        let id_ = object::new(ctx);
        let inner_ = object::uid_to_inner(&id_);
        let event = Event {
            id: id_,
            name,
            date,
            location,
            budget,
            tasks: table::new(ctx),
            participants: table::new(ctx),
            finished: false,
        };
        let cap = EventCap {
            id: object::new(ctx),
            event_id: inner_,
            owner: sender(ctx)
        };
        transfer::transfer(cap, sender(ctx));
        transfer::share_object(event);
    }

    public fun add_task(cap: &EventCap, self: &mut Event, name: String, assigned_to: address, ctx: &mut TxContext) {
        assert!(cap.event_id == object::id(self), ERROR_INVALID_CAP);

        let id_ = object::new(ctx);
        let task = Task {
            id: id_,
            name,
            assigned_to,
            completed: false,
        };
        table::add(&mut self.tasks, assigned_to, task);
    }

    public fun add_participant(self: &mut Event, name: String, ctx: &mut TxContext) {
        let id_ = object::new(ctx);
        let participant = Participant {
            id: id_,
            name,
            addr: sender(ctx),
            balance: balance::zero(),
        };
        table::add(&mut self.participants, sender(ctx), participant);
    }

    // public fun complete_task(planner : &mut EventPlanner,event_index: u64, task_index: u64) {
    //     let events = get_events(planner);
    //     let event = vector::borrow_mut(events, event_index);
    //     let task = vector::borrow_mut(&mut event.tasks, task_index);
    //     task.completed = true;
    // }

    // public fun finish_event(planner : &mut EventPlanner,event_index: u64) {
    //     let events = get_events(planner);
    //     let event = vector::borrow_mut(events, event_index);
    //     event.finished = true;
    // }

    // public fun get_event(planner: &mut EventPlanner, event_index: u64): &mut Event {
    //     let events = get_events(planner);
    //     return vector::borrow_mut(events, event_index)
    // }

    // public fun update_participant_balance(planner: &mut EventPlanner, event_index: u64, participant_index: u64, new_balance: Balance<SUI>, ctx: &mut TxContext) {
    //     let events = get_events(planner);
    //     let event = vector::borrow_mut(events, event_index);
    //     let participant = vector::borrow_mut(&mut event.participants, participant_index);
    //     participant.balance = new_balance;
    // }

    // public fun filter_events(planner: &mut EventPlanner, filter: fn(&Event) -> bool): vector<Event> {
    //     let events = get_events(planner);
    //     let mut filtered_events: vector<Event> = vector::empty();
    //     for event in events.iter() {
    //         if filter(event) {
    //             vector::push_back(&mut filtered_events, event.clone());
    //         }
    //     }
    //     return filtered_events;
    // }

    // public fun search_events(planner: &mut EventPlanner, search_term: String): vector<Event> {
    //     let events = get_events(planner);
    //     let search_results: vector<Event> = vector::empty();
    //     for (event in events.iter()) {
    //         if event.name.contains(&search_term) || event.location.contains(&search_term) {
    //         vector::push_back(&mut search_results, event.clone());
    //         }
    //     }
    //     return search_results;
    // }

    // public fun update_event(planner: &mut EventPlanner, event_index: u64, name: Option<String>, date: Option<String>, location: Option<String>, budget: Option<u64>, ctx: &mut TxContext) {
    //     let events = get_events(planner);
    //     let event = vector::borrow_mut(events, event_index);

    //     if (Some(new_name) = name) {
    //         event.name = new_name;
    //     };
    //     if (Some(new_date) = date) {
    //         event.date = new_date;
    //     };
    //     if (Some(new_location) = location) {
    //         event.location = new_location;
    //     };
    //     if (Some(new_budget) = budget) {
    //         event.budget = new_budget;
    //     }
    // }

}
