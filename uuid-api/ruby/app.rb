Cuba.use Rack::Session::Cookie, :secret => "idzbfxgtcurqwodxuy8Lywflaaqhp6bwbqbdgqouzdabuwgvrrxpuymhkkmxtgXesgdfhqearha"

Cuba.plugin Cuba::Safe

Cuba.define do
  on root do
    res.write JSON.dump({uuid: SecureRandom.uuid})
  end
end
