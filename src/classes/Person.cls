public abstract class Person  {
	protected final SObject obj;
	protected final Boolean isPersonLead;
	protected final Boolean isPersonContact;

	protected Person(SObject obj) {
		this.obj = obj;
	}

	protected String nameFormatter(String firstName, String lastName, String fullNameWhereAvailable) {
		String name = '';
		name += !String.isEmpty(firstName) ? firstName : '' ;
		name += !String.isEmpty(lastName) ? (String.isEmpty(name) ? lastName : ' ' + lastName) : '';

		//Fallback to the formula-field name, when available, in the event that neither of the actual name properties have been passed
		if(String.isEmpty(name) && fullNameWhereAvailable != null) name += fullNameWhereAvailable;
		return name;
	}

	protected abstract String getName();

	public SObject sObj {
		get { return this.obj; }
	}

	public Id Id {
		get { return this.obj.Id; }
	}

	public Boolean IsContact {
		get { return this.isPersonContact; }
	}

	public Boolean IsLead {
		get { return this.isPersonLead; }
	}

	public String Email {
		get { return this.obj.get('Email') == null ? '' : ((String) this.obj.get('Email')).toLowerCase(); }
	}

	public Boolean HasEmail {
		get {return !(String.isEmpty(this.Email)); }
	}

	public String Name {
		get {
			return this.getName();
		}
	}

	public String Phone {
		get { return this.obj.get('Phone') == null ? '' : ((String) this.obj.get('Phone')); }
	}

	public Boolean equals(Person two) {
		if(this.Id != null && two.Id != null) {
			return this.Id == two.Id;
		}
		return this.hashCode == two.hashCode;
	}

	//Doubles are 200x faster than decimals in Apex, but depending on your granularity needs, this can also be changed
	public Double hashCode {
		get {
			if(this.Email != null) {
				//If email address is not a unique identifier in your org, you should default to another email
				return (Double)this.Email.hashCode();
			} else {
				return((Object)this.sObj).hashCode();
			}
		}
	}

	public class Contact extends Person {
		private final Schema.Contact con;

		public Contact(Schema.Contact con) {
			super(con);
			this.con = con;
			this.isPersonLead = false;
			this.isPersonContact = true;
		}

		protected override String getName () {
			return this.nameFormatter(this.con.FirstName, this.con.LastName, this.con.Name);
		}
	}

	public class Lead extends Person {
		private final Schema.Lead lead;

		public Lead(Schema.Lead lead) {
			super(lead);
			this.lead = lead;
			this.isPersonLead = true;
			this.isPersonContact = false;
		}

		protected override String getName () {
			return this.nameFormatter(this.lead.FirstName, this.lead.LastName, this.lead.Name);
		}
	}

	//static factory methods
	public static Person get(SObject record) {
		return get(new List<SObject>{ record })[0];
	}

	public static Person get(Schema.Contact contact) {
		return new Person.Contact(contact);
	}

	public static Person get(Schema.Lead l) {
		return new Person.Lead(l);
	}

	public static List<Person> get(List<SObject> records) {
		List<Person> persons = new List<Person>();
		for(SObject record : records) {
			SObjectType objType = record.getSObjectType();
			if(objType == Schema.Contact.SObjectType) {
				persons.add(get((Schema.Contact)record));
			} else if (objType == Schema.Lead.SObjectType) {
				persons.add(get((Schema.Lead)record));
			} else {
				throw new InvalidPersonException('Person should be a lead or contact!');
			}
		}
		return persons;
	}

	public static Map<Id,Person> getPersonMap(Map<Id,SObject> sObjectMap) {
		Map<Id,Person> personMap = new Map<Id,Person>();
        for(SObject record : sObjectMap.values()) {
            personMap.put(record.Id, Person.get(record));
		}
        return personMap;
    }

	public static List<SObject> getSObjects(List<Person> persons) {
		List<SObject> records = new List<SObject>();
		for(Person person : persons) {
			records.add(person.sObj);
		}
		return records;
	}

	private class InvalidPersonException extends Exception {}
}