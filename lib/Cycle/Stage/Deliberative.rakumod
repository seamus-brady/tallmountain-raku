use v6.d;

class Cycle::Stage::Deliberative {
    # deliberative stage in the cognitive cycle - used for planning, reasoning, etc.
    # based on Aaron Sloman's CogAff architecture

    has $.LOGGER = Util::Logger.new(namespace => "<Cycle::Stage::Deliberative>");
    has Normative::Agent $.normative-agent;
}
