# Use Case

# Starting
- Create very basic neurosynaptic core

Split into various tasks
- Create router -> Rahim
    - fully connected topology
    - can handle inputs from all directions
    - establish simple handshaking protocol
    - able to send packets to scheduler

- Create Scheduler -> V, Eitan
    - is able to dequeue properly given length of previously dequeued instruction
    - has to be rotating fifos

- Create Controller -> Eitan, V
    - is able to recieve packet
    - is able to determine if input threshold is met
        - we are able to utilize weights and biases to determine if we want to do an instruction

- "Create" Neuron Block -> Rahim, Prarthik
    - basic alu with mulitplier for now
    - have output that is good for verification

- Gather up use cases -> Piyush

- setup testing environment -> V