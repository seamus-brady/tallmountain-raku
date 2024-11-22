use v6.d;

class Normative::Agent {
    # The normative subsystem of an agent. Contains all the endeavours of an agent.

    has @.endeavours;

    method add-endeavour(Normative::Role::Endeavour $endeavour) {
        @!endeavours.push($endeavour);
    }

    method get-endeavours() {
        return @!endeavours;
    }
}

