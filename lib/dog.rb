require 'pry'

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil,name:,breed:)
        @name=name
        @breed=breed
        @id=id
    end

    def self.create_table
        sql=<<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT  
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
    end

    def save
        if self.id
            self.update
        else
       sql=<<-SQL
       INSERT INTO dogs(name,breed)  
       VALUES (?,?)
       SQL
       DB[:conn].execute(sql,self.name,self.breed)
        @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
        end
    end

    def self.create(name:,breed:)
        dog=Dog.new(name: name,breed: breed)
        dog.save
        dog
    end
    def self.new_from_db(row)
        dog=self.new(id:row[0],name:row[1],breed:row[2])
    end

    def self.find_by_id(id)
        sql="SELECT * FROM dogs WHERE id=?;"
        DB[:conn].execute(sql,id).map {|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog=DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=? LIMIT 1;",name,breed)
        if !dog.empty?
            dog_data=dog[0]
            new_dog=self.new(id:dog_data[0],name:dog_data[1],breed:dog_data[2])
        else
         self.create(name:name,breed:breed)
        end
    end

    def self.find_by_name(name)
        sql="SELECT * FROM dogs WHERE name=? LIMIT 1;"
        DB[:conn].execute(sql,name).map {|row| new_from_db(row)}.first
    end

    def update
    sql="UPDATE dogs SET name=?, breed=? WHERE id=?;"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
    end

end