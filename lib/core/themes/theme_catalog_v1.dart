import 'theme_category.dart';
import 'theme_definition.dart';

/// Canonical Theme Dictionary V1 — shared vocabulary for all lenses.
abstract final class ThemeCatalogV1 {
  static const List<ThemeDefinition> all = [
  // --- Core Self (10) ---
  ThemeDefinition(
    id: 'independent',
    name: 'Independent',
    category: ThemeCategory.coreSelf,
    description: 'Tends to value autonomy and self-direction.',
  ),
  ThemeDefinition(
    id: 'disciplined',
    name: 'Disciplined',
    category: ThemeCategory.coreSelf,
    description: 'Tends to rely on structure, consistency, and self-control.',
  ),
  ThemeDefinition(
    id: 'curious',
    name: 'Curious',
    category: ThemeCategory.coreSelf,
    description: 'Tends to explore ideas and experiences with openness.',
  ),
  ThemeDefinition(
    id: 'practical',
    name: 'Practical',
    category: ThemeCategory.coreSelf,
    description: 'Tends to ground choices in what is workable and realistic.',
  ),
  ThemeDefinition(
    id: 'grounded',
    name: 'Grounded',
    category: ThemeCategory.coreSelf,
    description: 'Tends to seek stability and a steady sense of footing.',
  ),
  ThemeDefinition(
    id: 'visionary',
    name: 'Visionary',
    category: ThemeCategory.coreSelf,
    description: 'Tends to orient toward future possibilities and meaning.',
  ),
  ThemeDefinition(
    id: 'protective',
    name: 'Protective',
    category: ThemeCategory.coreSelf,
    description: 'Tends to guard what feels important, safe, or meaningful.',
  ),
  ThemeDefinition(
    id: 'adaptable',
    name: 'Adaptable',
    category: ThemeCategory.coreSelf,
    description: 'Tends to adjust approach when circumstances shift.',
  ),
  ThemeDefinition(
    id: 'creative',
    name: 'Creative',
    category: ThemeCategory.coreSelf,
    description: 'Tends to express identity through imagination and originality.',
  ),
  ThemeDefinition(
    id: 'ambitious',
    name: 'Ambitious',
    category: ThemeCategory.coreSelf,
    description: 'Tends to pursue growth, achievement, and forward momentum.',
  ),

  // --- Thinking Style (7) ---
  ThemeDefinition(
    id: 'analytical',
    name: 'Analytical',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to break problems into parts before deciding.',
  ),
  ThemeDefinition(
    id: 'strategic',
    name: 'Strategic',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to plan ahead and connect actions to longer-term goals.',
  ),
  ThemeDefinition(
    id: 'reflective',
    name: 'Reflective',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to pause and consider meaning before responding.',
  ),
  ThemeDefinition(
    id: 'big_picture',
    name: 'BigPicture',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to prioritize overall patterns over isolated details.',
  ),
  ThemeDefinition(
    id: 'detail_oriented',
    name: 'DetailOriented',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to notice specifics and refine accuracy.',
  ),
  ThemeDefinition(
    id: 'fast_moving',
    name: 'FastMoving',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to decide and act quickly when direction feels clear.',
  ),
  ThemeDefinition(
    id: 'systematic',
    name: 'Systematic',
    category: ThemeCategory.thinkingStyle,
    description: 'Tends to organize thought into ordered steps or frameworks.',
  ),

  // --- Emotional World (7) ---
  ThemeDefinition(
    id: 'empathetic',
    name: 'Empathetic',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to sense and resonate with others’ feelings.',
  ),
  ThemeDefinition(
    id: 'sensitive',
    name: 'Sensitive',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to experience emotions with depth and nuance.',
  ),
  ThemeDefinition(
    id: 'stable',
    name: 'Stable',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to maintain emotional steadiness under pressure.',
  ),
  ThemeDefinition(
    id: 'expressive',
    name: 'Expressive',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to show feelings openly when safe to do so.',
  ),
  ThemeDefinition(
    id: 'reserved',
    name: 'Reserved',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to keep inner feelings private until trust is built.',
  ),
  ThemeDefinition(
    id: 'resilient',
    name: 'Resilient',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to recover and adapt after emotional strain.',
  ),
  ThemeDefinition(
    id: 'calm_under_pressure',
    name: 'CalmUnderPressure',
    category: ThemeCategory.emotionalWorld,
    description: 'Tends to stay composed when stress or urgency rises.',
  ),

  // --- Relationships (6) ---
  ThemeDefinition(
    id: 'loyal',
    name: 'Loyal',
    category: ThemeCategory.relationships,
    description: 'Tends to stay committed once trust is established.',
  ),
  ThemeDefinition(
    id: 'supportive',
    name: 'Supportive',
    category: ThemeCategory.relationships,
    description: 'Tends to offer care and encouragement to others.',
  ),
  ThemeDefinition(
    id: 'relationship_oriented',
    name: 'RelationshipOriented',
    category: ThemeCategory.relationships,
    description: 'Tends to prioritize connection and mutual understanding.',
  ),
  ThemeDefinition(
    id: 'independent_in_relationships',
    name: 'IndependentInRelationships',
    category: ThemeCategory.relationships,
    description: 'Tends to value personal space within close bonds.',
  ),
  ThemeDefinition(
    id: 'protective_of_others',
    name: 'ProtectiveOfOthers',
    category: ThemeCategory.relationships,
    description: 'Tends to look out for people who matter.',
  ),
  ThemeDefinition(
    id: 'diplomatic',
    name: 'Diplomatic',
    category: ThemeCategory.relationships,
    description: 'Tends to navigate differences with tact and balance.',
  ),

  // --- Work & Ambition (7) ---
  ThemeDefinition(
    id: 'builder',
    name: 'Builder',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to create durable results through steady effort.',
  ),
  ThemeDefinition(
    id: 'leader',
    name: 'Leader',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to guide direction and motivate others.',
  ),
  ThemeDefinition(
    id: 'explorer',
    name: 'Explorer',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to seek new domains, roles, or experiences.',
  ),
  ThemeDefinition(
    id: 'specialist',
    name: 'Specialist',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to deepen expertise in a focused area.',
  ),
  ThemeDefinition(
    id: 'teacher',
    name: 'Teacher',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to share knowledge and help others grow.',
  ),
  ThemeDefinition(
    id: 'entrepreneurial',
    name: 'Entrepreneurial',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to initiate opportunities and take calculated risks.',
  ),
  ThemeDefinition(
    id: 'innovator',
    name: 'Innovator',
    category: ThemeCategory.workAndAmbition,
    description: 'Tends to improve systems through new ideas and approaches.',
  ),

  // --- Strengths (7) ---
  ThemeDefinition(
    id: 'persistence',
    name: 'Persistence',
    category: ThemeCategory.strengths,
    description: 'Tends to keep going despite obstacles or slow progress.',
  ),
  ThemeDefinition(
    id: 'communication',
    name: 'Communication',
    category: ThemeCategory.strengths,
    description: 'Tends to convey ideas clearly and connect through dialogue.',
  ),
  ThemeDefinition(
    id: 'adaptability',
    name: 'Adaptability',
    category: ThemeCategory.strengths,
    description: 'Tends to flex approach when conditions change.',
  ),
  ThemeDefinition(
    id: 'leadership',
    name: 'Leadership',
    category: ThemeCategory.strengths,
    description: 'Tends to inspire confidence and coordinate effort.',
  ),
  ThemeDefinition(
    id: 'creativity',
    name: 'Creativity',
    category: ThemeCategory.strengths,
    description: 'Tends to generate fresh ideas and novel solutions.',
  ),
  ThemeDefinition(
    id: 'empathy',
    name: 'Empathy',
    category: ThemeCategory.strengths,
    description: 'Tends to understand others’ perspectives and needs.',
  ),
  ThemeDefinition(
    id: 'reliability',
    name: 'Reliability',
    category: ThemeCategory.strengths,
    description: 'Tends to follow through on commitments consistently.',
  ),

  // --- Growth Areas (7) ---
  ThemeDefinition(
    id: 'perfectionism',
    name: 'Perfectionism',
    category: ThemeCategory.growthAreas,
    description: 'May hold overly high standards that slow progress or ease.',
  ),
  ThemeDefinition(
    id: 'impulsiveness',
    name: 'Impulsiveness',
    category: ThemeCategory.growthAreas,
    description: 'May act quickly before fully weighing consequences.',
  ),
  ThemeDefinition(
    id: 'overthinking',
    name: 'Overthinking',
    category: ThemeCategory.growthAreas,
    description: 'May loop on analysis instead of moving forward.',
  ),
  ThemeDefinition(
    id: 'avoidance',
    name: 'Avoidance',
    category: ThemeCategory.growthAreas,
    description: 'May withdraw from discomfort rather than address it.',
  ),
  ThemeDefinition(
    id: 'self_criticism',
    name: 'SelfCriticism',
    category: ThemeCategory.growthAreas,
    description: 'May judge oneself harshly even when effort is sufficient.',
  ),
  ThemeDefinition(
    id: 'control',
    name: 'Control',
    category: ThemeCategory.growthAreas,
    description: 'May over-manage outcomes when uncertainty feels uneasy.',
  ),
  ThemeDefinition(
    id: 'people_pleasing',
    name: 'PeoplePleasing',
    category: ThemeCategory.growthAreas,
    description: 'May prioritize others’ approval over personal needs.',
  ),

  // --- Growth Path (6) ---
  ThemeDefinition(
    id: 'trust_yourself_more',
    name: 'TrustYourselfMore',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from building inner confidence in judgment.',
  ),
  ThemeDefinition(
    id: 'open_to_collaboration',
    name: 'OpenToCollaboration',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from sharing effort and perspective with others.',
  ),
  ThemeDefinition(
    id: 'develop_patience',
    name: 'DevelopPatience',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from allowing processes to unfold at a natural pace.',
  ),
  ThemeDefinition(
    id: 'embrace_change',
    name: 'EmbraceChange',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from adapting when life shifts direction.',
  ),
  ThemeDefinition(
    id: 'express_emotions_more_freely',
    name: 'ExpressEmotionsMoreFreely',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from sharing feelings in safe, honest ways.',
  ),
  ThemeDefinition(
    id: 'balance_structure_with_flexibility',
    name: 'BalanceStructureWithFlexibility',
    category: ThemeCategory.growthPath,
    description: 'Growth may come from blending order with openness to adjustment.',
  ),
  ];
}
