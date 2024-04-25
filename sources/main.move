module dacade_deepbook::book {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::transfer::{Self};
    use sui::table::{Self, Table};

    use std::vector;

     // === Errors ===
    const ERROR_INVALID_CAP: u64 = 0;
    const ERROR_EVENT_FINISHED: u64 = 1;


     // === Structs ===
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

     // === Public-Mutative Functions ===

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

    public fun complete_task(self: &mut Event, ctx: &mut TxContext) {
        assert!(!self.finished, ERROR_EVENT_FINISHED);
        let task = table::borrow_mut(&mut self.tasks, sender(ctx));
        task.completed = true;
    }

    public fun finish_event(cap: &EventCap, self: &mut Event) {
        assert!(cap.event_id == object::id(self), ERROR_INVALID_CAP);
        self.finished = true;
    }

    public fun update_participant_balance(cap: &EventCap, self: &mut Event, participant: address, coin: Coin<SUI>) {
        assert!(cap.event_id == object::id(self), ERROR_INVALID_CAP);
        let participiant = table::borrow_mut(&mut self.participants, participant);
        let balance_ = coin::into_balance(coin);
        balance::join(&mut participiant.balance, balance_);
    }

   // === Public-View Functions ===

    // Event
    public fun get_event_name(self: &Event) : String {
        self.name
    }
    public fun get_event_date(self: &Event) : String {
        self.date
    }
    public fun get_event_location(self: &Event) : String {
        self.location
    }
     public fun get_event_budget(self: &Event) : u64 {
        self.budget
    }
    public fun get_event_finished(self: &Event) : bool {
        self.finished
    }
    // Task
    public fun get_task_name(self: &Task) : String {
        self.name
    }
    public fun get_task_assigned(self: &Task) : address {
        self.assigned_to
    }
    public fun get_task_completed(self: &Task) : bool {
        self.completed
    }

    // Participant
    public fun get_part_completed(self: &Participant) : String {
        self.name
    }

    public fun get_part_addr(self: &Participant) : address {
        self.addr
    }
    public fun get_part_balance(self: &Participant) : u64 {
        let balance_ = balance::value(&self.balance);
        balance_
    }
}
