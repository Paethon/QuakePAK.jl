module QuakePAK

struct PakFileEntry
  name:: String
  offset:: Int
  size:: Int
end

struct PakFile
  pakfilename::String
  files::Vector{PakFileEntry}
end

function read_file_entry(io::IO)
  pos = position(io)
  name = readuntil(io, '\0')
  seek(io, pos+56)
  offset = read(io, Int32)
  size = read(io, Int32)
  return PakFileEntry(name, offset, size)
end

function open_pak(filename::String)
  fileentries = []
  open(filename) do f
    # Check if the file is a PAK-File
    id = Vector{Cchar}(undef, 4)
    read!(io, id)
    @assert String(Char.(id)) == "PACK"
    # Read meta data
    offset = read(io, Int32)      # Where the file entries start
    size = read(io, Int32)        # Size of file entry table
    nbentries = size÷64           # Each file entry is 64 bytes long
    # Iterate over all file entries
    seek(io, offset)
    fileentries = [read_file_entry(io) for _ in 1:nbentries]
  end
  return PakFile(filename, fileentries)
end

export open_pak

end # module
