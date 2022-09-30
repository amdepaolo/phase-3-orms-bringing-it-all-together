class Dog

    attr_accessor :name, :breed, :id

    def initialize (name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
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
        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
    end

    def self.create(name:, breed:)
        dog  = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        DB[:conn].execute("SELECT * FROM dogs").map do |row|
            Dog.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
            SQL
        DB[:conn].execute(sql, name).map do |row|
            Dog.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
            SQL
        DB[:conn].execute(sql, id).map do |row|
            Dog.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE name = ?
            AND breed = ?
            SQL
        results = DB[:conn].execute(sql, name, breed)
        if results.length == 0
           return Dog.create(name: name, breed: breed)
        else
            Dog.new_from_db(results[0])
        end
    end

    def update 
        sql = <<-SQL
            UPDATE dogs
            SET name = ?
            WHERE id = ?
            SQL
        DB[:conn].execute(sql, self.name, self.id)
    end

end
