class DeduplicaVacios < ActiveRecord::Migration[7.0]
  def up
    puts "Personas sin nombre a quienes se les pondrá N: "\
      "#{Sip::Persona.where(
        "nombres IS NULL OR TRIM(nombres)=''").count}"
    execute <<-SQL
      UPDATE sip_persona SET nombres='N' 
        WHERE nombres IS NULL OR TRIM(nombres)=''
      ;
    SQL

    puts "Personas sin apellidos a quienes se les pondrá N: "\
      "#{Sip::Persona.where(
        "apellidos IS NULL OR TRIM(apellidos)=''").count}"
    execute <<-SQL
      UPDATE sip_persona SET apellidos='N' 
        WHERE apellidos IS NULL OR TRIM(apellidos)=''
      ;
    SQL

    puts "Personas con número de documento en blanco "\
      "(se les pondrá tipo SIN DOCUMENTO y el número será la identificación):"\
      "#{Sip::Persona.where(
        "numerodocumento IS NULL OR TRIM(numerodocumento)=''").count}"
    execute <<-SQL
      UPDATE sip_persona SET tdocumento_id=11,
        numerodocumento=id WHERE numerodocumento IS NULL
        OR TRIM(numerodocumento)=''
      ;
    SQL

    puts "Personas sin tipo de documento a quienes se les pondrá "\
      "tipo SIN DOCUMENTO manteniendo el número de documento que tenían: "\
      "#{Sip::Persona.where("tdocumento_id IS NULL").count}"
    execute <<-SQL
      UPDATE sip_persona SET tdocumento_id=11 WHERE tdocumento_id IS NULL;
    SQL

    puts "Dejando personas a las que se les cambió el número de documento en "\
      "/tmp/porcambiarnumero.tsv"
    File.open('/tmp/porcambiarnumero.tsv', 'w') do |agarradero|
      l = "id  \t tipo_documento  \t numero_docuento \t nombres \t apellidos"
      puts l
      agarradero.write l+"\n"
      (1..4).each do |i|
        dup = "SELECT p2.id FROM sip_persona AS p1 "\
          "JOIN sip_persona AS p2 ON p1.id<p2.id "\
          "AND (p1.tdocumento_id=11) "\
          "AND (p2.tdocumento_id=11) "\
          "AND TRIM(p1.numerodocumento)=TRIM(p2.numerodocumento)"
        edup = Sip::Persona.where("id IN (#{dup})").order(:id)
        puts "Ronda #{i} de deduplicación de #{edup.count} pares de personas "\
          "SIN DOCUMENTO con número de documento duplicado. Se cambiará "\
          "número de documento a la segunda persona de cada pareja."
        edup.each do |p|
          l="#{p.id} \t #{p.tdocumento ? p.tdocumento.sigla : ''} \t "\
            "#{p.numerodocumento} \t #{p.nombres} \t #{p.apellidos}"
          puts l
          agarradero.write l+"\n"
          p.numerodocumento = p.id
          p.save
          Sip::Persona.where(tdocumento_id: 11).
            where(numerodocumento: p.numerodocumento).
            where.not(id: p.id).each do |rp|
            puts "De-depulicando re-repetido"
            l="#{rp.id} \t #{rp.tdocumento ? rp.tdocumento.sigla : ''} \t "\
              "#{rp.numerodocumento} \t #{rp.nombres} \t #{rp.apellidos}"
            puts l
            agarradero.write l+"\n"
            rp.numerodocumento = rp.id
            rp.save
          end
        end
      end
    end
  end

  def down
    #raise IrreversibleMigration
  end
end
