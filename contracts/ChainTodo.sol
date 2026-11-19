// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainTodo {
    struct Tugas {
        string judul;
        bool selesai;
        uint256 dibuat;
        address pembuat;
    }

    Tugas[] private daftar;

    event TugasBaru(uint256 id, string judul, address pembuat);
    event TugasSelesai(uint256 id);

    function tambahTugas(string calldata judul) external {
        require(bytes(judul).length > 0, "Judul tidak boleh kosong");
        daftar.push(Tugas(judul, false, block.timestamp, msg.sender));
        emit TugasBaru(daftar.length - 1, judul, msg.sender);
    }

    function tandaiSelesai(uint256 id) external {
        require(id < daftar.length, "Tugas tidak ada");
        require(daftar[id].pembuat == msg.sender, "Bukan pembuat tugas");
        daftar[id].selesai = true;
        emit TugasSelesai(id);
    }

    function jumlahTugas() external view returns (uint256) {
        return daftar.length;
    }

    function ambilTugas(uint256 id)
        external
        view
        returns (string memory, bool, uint256, address)
    {
        require(id < daftar.length, "Tugas tidak ada");
        Tugas memory t = daftar[id];
        return (t.judul, t.selesai, t.dibuat, t.pembuat);
    }
}
