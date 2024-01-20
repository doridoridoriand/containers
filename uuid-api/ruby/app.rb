Cuba.use Rack::Session::Cookie, :secret => "idzbfxgtcurqwodxuy8Lywflaaqhp6bwbqbdgqouzdabuwgvrrxpuymhkkmxtgXesgdfhqearha"

Cuba.plugin Cuba::Safe

# ref. https://github.com/rack/rack/blob/main/lib/rack/lint.rb#L655-L656
Cuba.define do
  on root do
    res.headers.keys.each do |key|
      res.headers[key.downcase] = res.headers.delete(key)
    end
    res.json JSON.dump({uuid: SecureRandom.uuid})
  end
end
