# *_Please send any request to Github (See Source URL!)_*
This framework allows to handle events, entities and prototypes
# Handle events
Some events are handle automatically for creation/remove of entity, on_tick etc.
However, it is always possible to execute custom functions when a script is called:
Simply add the function to the table list_events[<name of the evemt>]

extra event: on_removed, and on_built can be used as name of events, and group all events which respectively create/destroy entites

# Define Prototype
A __custom_prototype__ is a table or boolean **true** that defines custom properties of an entity or train.
It is defined as following:
``` custom_prototypes[<identifier>]=<custom_prototype> ```
__identifier__ can be the name of type of the entity for which prototype shall apply.
for train, it is the word "train"
Finally, it is possible to use it for all entities, by using the keyword "any"

# Create entity/train
When an entity is built, if there is a matching prototype, a __custom_entity__ is created with properties of the prototype. 
__custom_entity__ has at least one property mandatory, __entity__ which is either an entity or a train, and need to exist and to be valid.
__custom_entity__ can be created per default or through the method "new" (new is eypected to send back the __custom_entity__)
__custom_entity__ is then stored automatically in the table __global.custom_entities__
 and indexed through __entity.unit_number__ (if this is an entity) or __entity.id__ (if this is a train) 
Then, - __custom_entity__:on_built is called if it exists

# Remove entity/train
If the entity has a __custom_entity__, this one is automatically removed from the table __global.custom_entities__
Additionally, the method __custom_entity__:on_removed can be called, if it exists
