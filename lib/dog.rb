class Dog
  attr_accessor :name,:breed, :id
  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end  
  
  def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
      SQL
 
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Dog.new(id:result[0],name:result[1],breed:result[2])    
  end
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      result = dog[0]
      dog = Dog.new(id:result[0],name:result[1],breed:result[2]) 
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end 
  
  def self.new_from_db(row)
  	pat = Dog.new(id:row[0],name:row[1],breed:row[2])
  	pat    
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end

=begin


  describe '.find_by_name' do
    it 'returns an instance of dog that matches the name from the DB' do
      teddy.save
      teddy_from_db = Dog.find_by_name("Teddy")

      expect(teddy_from_db.name).to eq("Teddy")
      expect(teddy_from_db.id).to eq(1)
      expect(teddy_from_db).to be_an_instance_of(Dog)
    end
  end

  describe '#update' do
    it 'updates the record associated with a given instance' do
      teddy.save
      teddy.name = "Teddy Jr."
      teddy.update
      teddy_jr = Dog.find_by_name("Teddy Jr.")
      expect(teddy_jr.id).to eq(teddy.id)
    end

  end

end
=end
