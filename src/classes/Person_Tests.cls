@isTest
private class Person_Tests {
    @isTest
    static void it_should_setup_lead_properly() {
        Lead lead = getLead();
        Person p = Person.get(lead);

        System.assertEquals(lead.FirstName + ' ' + lead.LastName, p.Name);
        System.assertEquals(lead.Email, p.Email);
        System.assertEquals(lead.Phone, p.Phone);
        System.assert(p.IsLead);
        System.assert(p.HasEmail);
    }

    @isTest
    static void it_should_setup_contact_properly() {
        Contact con = new Contact(FirstName = 'Parson', LastName = 'Field', Email = 'eggs@ham.com', Phone = '345-123-1234');
        Person p = Person.get(con);

        System.assertEquals(con.FirstName + ' ' + con.LastName, p.Name);
        System.assertEquals(con.Email, p.Email);
        System.assertEquals(con.Phone, p.Phone);
        System.assert(p.IsContact);
        System.assert(p.HasEmail);
    }

    @isTest
    static void it_should_properly_compare_persons() {
        Lead lead = getLead();
        Person leadPerson = Person.get(lead);
        Person secondPerson = leadPerson;

        System.assert(leadPerson.equals(secondPerson), 'Equality is broken if this fails!');

        //"test" again through the Id route
        Id fakeId = '00Q000000000001';
        lead.Id = fakeId;
        System.assert(leadPerson.equals(secondPerson), 'Equality is broken if this fails!');
    }

    @isTest
    static void it_should_throw_exception_for_non_contact_or_lead() {
        try {
            Person p = Person.get(new Account());
            System.assert(false, 'Should not make it here.');
        } catch(Exception ex) {}
    }

    @isTest
    static void it_should_return_a_list_of_sobjects_when_starting_with_a_person_list() {
        Lead lead = getLead();
        List<Person> persons = new List<Person>{ Person.get(lead) };

        try {
            List<SObject> objects = Person.getSObjects(persons);
        } catch (Exception ex) {
            System.assert(false, ex);
        }
    }

    @isTest
    static void it_should_return_a_map_of_persons_when_starting_with_an_sobject_map() {
        Lead lead = getLead();
        lead.Company = 'Fake Company';
        insert lead;

        Map<Id,Lead> leadMap = new Map<Id,Lead>(new List<Lead>{ lead });

        try{
            Map<Id,Person> personMap = Person.getPersonMap(leadMap);
        } catch (Exception ex) {
            System.assert(false, ex);
        }
    }

    static Lead getLead() {
        return new Lead(FirstName = 'Parson', LastName = 'Field', Email = 'eggs@ham.com', Phone = '345-123-1234');
    }
}