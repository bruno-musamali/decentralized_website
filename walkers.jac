// walkers.jac
// Multi-agent orchestration walkers

import {user, topic, knowledge_base, mastery} from "./main.jac";

walker user_manager {
    // Register new user
    can register with entry (username: str, email: str? = null) -> node::user {
        new_user = spawn node::user(username=username, email=email);
        report new_user;
    }
}

walker progress_agent {
    // Agent 3: Progress Agent – evaluates quiz + updates mastery (OSP state)
    can submit_quiz with entry (
        topic_name: str,
        questions: list[Question],
        answers: list[str]
    ) -> dict {
        kb = (root --> node::knowledge_base)[0];
        target_topic = (kb --> node::topic(name==topic_name))[0];

        evals = target_topic.evaluate_answers(questions, answers);
        avg_score = sum(e.score for e in evals) / len(evals);

        // Weighted moving average – favors recent performance
        m_edge = (here --> mastery --> target_topic);
        if m_edge {
            m = m_edge[0];
            m.attempts += 1;
            m.level = (m.level * (m.attempts - 1) + avg_score) / m.attempts;
        } else {
            spawn here --> mastery(level=avg_score, attempts=1) --> target_topic;
        }

        report {
            "average_score": avg_score,
            "evaluations": evals,
            "new_proficiency": m_edge ? m_edge[0].level : avg_score
        };
    }
}

walker recommender_agent {
    // Agent 4: Recommender Agent – full skill map + adaptive recommendations
    can get_skill_map with entry -> dict {
        kb = (root --> node::knowledge_base)[0];
        topics = kb --> node::topic;

        result = [];
        recommended = [];

        for t in topics {
            m = (here --> mastery --> t);
            prof = m ? m[0].level : 0.0;

            // Unlock logic: all prerequisites ≥ 0.8
            unlocked = true;
            for pre in (t <-- prereq) {
                pre_prof = ((here --> mastery --> pre.from_node)[0].level || 0.0);
                if pre_prof < 0.8 { unlocked = false; break; }
            }

            is_suggested = unlocked and prof < 0.75;

            result.append({
                "topic": t.name,
                "proficiency": prof,
                "unlocked": unlocked,
                "suggested": is_suggested
            });

            if is_suggested { recommended.append(t.name); }
        }

        // Sort recommendations by lowest proficiency
        recommended.sort(key=lambda n: [s.proficiency for s in result if s.topic==n][0]);

        report {
            "skills": result,
            "recommended_next": recommended[:3],
            "total_topics": len(topics)
        };
    }
}