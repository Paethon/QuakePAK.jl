module QuakePAK

const _fileid = 0x5041434b      # The chars "PACK" used as a signature of PAK archives

struct ReadableFile <: IO
  _io::IO
  filename:: String
  offset:: Int
  size:: Int
end

Base.position(rf::ReadableFile) = position(rf._io) - rf.offset
Base.eof(rf.ReadableFile) = position(rf._io) < rf.offset + rf.size

Base.show(io::IO,  p::PakFileEntry) =
  print(io, "$(p.pak_filename)/$(p.filename) [offset: $(p.offset), size: $(p.size) byte]")

function read_file_entry(io::IO)
  pos = position(io)
  name = readuntil(io, '\0')
  seek(io, pos+56)
  offset = read(io, Int32)
  size = read(io, Int32)
  return name, offset, size
end

function open_pak(filename::String)
  fileentries = []
  open(filename) do f
    # Check if the file is a PAK-File
    @assert read(f, UInt32) == _fileid
    # Read meta data
    offset = read(f, Int32)      # Where the file entries start
    size = read(f, Int32)        # Size of file entry table
    nbentries = size÷64          # Each file entry is 64 bytes long
    # Iterate over all file entries
    seek(f, offset)
    for _ in 1:nbentries
      name, offset, size = read_file_entry(f)
      push!(fileentries, PakFileEntry(filename, name, offset, size))
    end
  end
  return fileentries
end

export open_pak

end # module
