# agents: LLM agents attached to topic node

include "./main.jac";
import {llm} from "byllm.lib";

node::topic {
    # Agent 1: Quiz Generator (Generative)
    can generate_quiz with entry (num_questions: int = 5) -> list[Question] {
        """You are an expert Jaseci instructor. 
        Generate exactly {num_questions} deep, free-text questions (not MCQ) about '{here.name}'.
        Full topic description: {here.description}
        Questions must test understanding, not memorization.
        Vary difficulty around user's current level.
        Return ONLY the JSON list of Question objects. No extra text."""
    } by llm();

    # Agent 2: Answer Evaluator (Analytical + Generative feedback)
    can evaluate_answers with entry (questions: list[Question], answers: list[str]) -> list[Evaluation] {
        """You are a strict but fair Jasea examiner for topic '{here.name}'.
        For each question and user answer, give:
        - score (0.0–1.0)
        - detailed educational feedback
        - correct = true if score >= 0.80"""
    } by llm();
}