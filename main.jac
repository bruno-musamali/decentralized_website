
import byllm.lib as byllm;

obj Question {
    has text: str;
    has difficulty: str = "medium";
}

obj Evaluation {
    has score: float;
    has feedback: str;
    has correct: bool;
}

node knowledge_base;

node topic {
    has name: str;
    has description: str;
}

node user {
    has username: str;
    has email: str = "";
}

edge prereq;
edge mastery;

obj Mastery {
    has level: float = 0.0;
    has attempts: int = 0;
}
walker InitKnowledgeBase {
    topics = [
        ("Jac Basics", "Introduction to Jac syntax, variables, control flow, and basic programming in Jac."),
        ("Nodes & Edges", "Defining nodes, edges, object-oriented features, and connecting objects."),
        ("Walkers & Abilities", "Creating walkers, abilities, entry/exit, walker execution."),
        ("Graphs & Connections", "Building graphs, connect operators, filtering, traversal."),
        ("OSP Paradigm", "Object-Spatial Programming, spatial reasoning over object graphs."),
        ("byLLM Integration", "byLLM decorator, structured outputs, ReAct agents, context-aware methods."),
        ("Jac Client", "Reactive frontends, Spawn(), real-time walker calls, UI components.")
    ];

    for topic in topics {
        n = topic[0];
        desc = topic[1];
        if !(kb --> node::topic(name==n)) {
            spawn kb --> node::topic(name=n, description=desc);
        }
    }

        // Prerequisite chain
        basics     = (kb --> node::topic(name=="Jac Basics"))[0];
        nodes      = (kb --> node::topic(name=="Nodes & Edges"))[0];
        walkers    = (kb --> node::topic(name=="Walkers & Abilities"))[0];
        graphs     = (kb --> node::topic(name=="Graphs & Connections"))[0];
        osp        = (kb --> node::topic(name=="OSP Paradigm"))[0];
        byllm      = (kb --> node::topic(name=="byLLM Integration"))[0];
        jacclient  = (kb --> node::topic(name=="Jac Client"))[0];

        basics --> prereq --> nodes;
        basics --> prereq --> walkers;
        nodes  --> prereq --> graphs;
        walkers --> prereq --> graphs;
        graphs --> prereq --> osp;
        osp    --> prereq --> byllm;
        osp    --> prereq --> jacclient;
}