#[allow(unused_use)]
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

    // Structs
    struct Event {
        id: UID,
        name: String,
        date: String,
        location: String,
        budget: u64,
        tasks: vector<Task>,
        participants: vector<Participant>,
        finished: bool,
    }

    struct Task {
        id: UID,
        name: String,
        assigned_to: UID,
        completed: bool,
    }

    struct Participant {
        id: UID,
        name: String,
        balance: Balance<SUI>,
    }

    struct EventPlanner {
        id: UID,
        events: vector<Event>,
    }

    // Initialization function
    fun init(ctx: &mut TxContext) {
        let planner = EventPlanner {
            id: object::new(ctx),
            events: vector::empty<Event>(),
        };
        share_object(planner);
    }

    // Helper function to get events from planner
    fun get_events(planner: &mut EventPlanner) -> &mut vector<Event> {
        return &mut planner.events;
    }

    // Public function to add an event to the planner
    public fun add_event(planner: &mut EventPlanner, name: String, date: String, location: String, budget: u64, ctx: &mut TxContext) {
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

    // Public function to add a task to an event
    public fun add_task(planner: &mut EventPlanner, event_index: u64, name: String, assigned_to: UID, ctx: &mut TxContext) {
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

    // Public function to add a participant to an event
    public fun add_participant(planner: &mut EventPlanner, event_index: u64, name: String, ctx: &mut TxContext) {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let new_participant_id = object::new(ctx);
        let new_participant = Participant {
            id: new_participant_id,
            name,
            balance: Balance::zero(),
        };
        vector::push_back(&mut event.participants, new_participant);
    }

    // Public function to mark a task as completed
    public fun complete_task(planner: &mut EventPlanner, event_index: u64, task_index: u64) -> Result<(), String> {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let task = vector::get_mut(&mut event.tasks, task_index as usize);
        match task {
            Some(task) => {
                task.completed = true;
                Ok(())
            }
            None => Err("Task not found".to_string()),
        }
    }

    // Public function to mark an event as finished
    public fun finish_event(planner: &mut EventPlanner, event_index: u64) -> Result<(), String> {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        event.finished = true;
        Ok(())
    }

    // Public function to get an event by its index
    public fun get_event_by_index(planner: &mut EventPlanner, event_index: u64) -> Option<&mut Event> {
        let events = get_events(planner);
        return vector::get_mut(events, event_index as usize);
    }

    // Public function to get an event by its ID
    public fun get_event_by_id(planner: &mut EventPlanner, event_id: UID) -> Option<&mut Event> {
        let events = get_events(planner);
        for event in events.iter_mut() {
            if event.id == event_id {
                return Some(event);
            }
        }
        None
    }

    // Helper function to get the index of an event by its ID
    fun get_event_index(planner: &mut EventPlanner, event_id: UID) -> Option<u64> {
        for (index, event) in planner.events.iter().enumerate() {
            if event.id == event_id {
                return Some(index as u64);
            }
        }
        None
    }

    // Public function to update the balance of a participant
    public fun update_participant_balance(planner: &mut EventPlanner, event_index: u64, participant_index: u64, new_balance: Balance<SUI>, ctx: &mut TxContext) -> Result<(), String> {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        let participant = vector::get_mut(&mut event.participants, participant_index as usize);
        match participant {
            Some(participant) => {
                participant.balance = new_balance;
                Ok(())
            }
            None => Err("Participant not found".to_string()),
        }
    }

    // Public function to filter events based on a custom filter function
    public fun filter_events(planner: &mut EventPlanner, filter: fn(&Event) -> bool) -> vector<Event> {
        let events = get_events(planner);
        let mut filtered_events: vector<Event> = vector::empty();
        for event in events.iter() {
            if filter(event) {
                vector::push_back(&mut filtered_events, event.clone());
            }
        }
        return filtered_events;
    }

    // Public function to search events by name or location
    public fun search_events(planner: &mut EventPlanner, search_term: String) -> vector<Event> {
        let events = get_events(planner);
        let mut search_results: vector<Event> = vector::empty();
        for event in events.iter() {
            if event.name.contains(&search_term) || event.location.contains(&search_term) {
                vector::push_back(&mut search_results, event.clone());
            }
        }
        return search_results;
    }

    // Public function to update event details
    public fun update_event(planner: &mut EventPlanner, event_index: u64, name: Option<String>, date: Option<String>, location: Option<String>, budget: Option<u64>, ctx: &mut TxContext) -> Result<(), String> {
        let events = get_events(planner);
        let event = vector::borrow_mut(events, event_index);
        if let Some(new_name) = name {
            event.name = new_name;
        }
        if let Some(new_date) = date {
            event.date = new_date;
        }
        if let Some(new_location) = location {
            event.location = new_location;
        }
        if let Some(new_budget) = budget {
            event.budget = new_budget;
        }
        Ok(())
    }
}
