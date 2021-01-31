﻿using Model;
using System;
using System.Collections.Generic;

namespace Services.Trajanja
{
    public class TrajanjeService : ITrajanjeService
    {
        private DbService db = DbService.GetInstance();

        public List<Trajanje> GetAllTrajanja()
        {
            return db.GetAllTrajanja();
        }
    }
}