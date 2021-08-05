""" easysql3 - Easy SQLite3 Wrapper Classes

    Author: Halley Tsai <hftsai256@gmail.com>
    Date: August, 2021

    Provide straight-forwarded browsing experiences when using interactive shells
"""
import sqlite3
from collections import namedtuple

class ColSQL3():
    def __init__(self, table, col, cur):
        self._table = table
        self._col = col
        self._cur = cur
    
    def __getitem__(self, key):
        query = (f"SELECT * FROM {self._table} "
                 f"WHERE ({self._col} = '{key}')")
        self._cur.execute(query)
        return self._cur.fetchall()
    
    @property
    def values(self):
        query = (f"SELECT {self._col} FROM {self._table}")
        self._cur.execute(query)
        return tuple(key for names in self._cur.fetchall() for key in names)

    @property
    def uniques(self):
        query = (f"SELECT DISTINCT {self._col} FROM {self._table}")
        self._cur.execute(query)
        return tuple(key for names in self._cur.fetchall() for key in names)


class TableSQL3():
    def __init__(self, table, cur):
        self._table = table
        self._cur = cur
        
    def __repr__(self):
        return f'type(self), cols={self.columns}'

    @property
    def columns(self):
        query = (f'SELECT * FROM {self._table} LIMIT 0')
        data = self._cur.execute(query)
        return tuple(d[0] for d in data.description)
    
    def __getattr__(self, attr):
        if attr not in self.columns:
            raise AttributeError
        else:
            return ColSQL3(self._table, attr, self._cur)

    def query(self, condition):
        Entry = namedtuple('Entry', self.columns)
        cond = condition.replace('==', '=')
        query = (f"SELECT * from {self._table} "
                 f"WHERE {cond}")
        self._cur.execute(query)
        return [Entry(*inp) for inp in self._cur.fetchall()]
    
    def full(self):
        Entry = namedtuple('Entry', self.columns)
        query = (F"SELECT * FROM {self._table}")
        self._cur.execute(query)
        return [Entry(*inp) for inp in self._cur.fetchall()]


class DataBaseSQL3():
    def __init__(self, db):
        self._con = sqlite3.connect(db)
        self._cur = self._con.cursor()
        self._con.row_factory = sqlite3.Row
        
    def __repr__(self):
        return f'{type(self)}, tables={self.tables}'
        
    @property
    def tables(self):
        query = ('SELECT name FROM sqlite_master '
                 'WHERE type IN ("table", "view") '
                 'AND name NOT LIKE "sqlite_%" '
                 'ORDER BY 1')
        self._cur.execute(query)
        return tuple(key for names in self._cur.fetchall() for key in names)
    
    def __getattr__(self, attr):
        if attr not in self.tables:
            raise AttributeError('')
        else:
            return TableSQL3(attr, self._cur)

