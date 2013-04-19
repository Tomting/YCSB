/**
 * Copyright (c) 2010 Yahoo! Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License. You
 * may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License. See accompanying
 * LICENSE file.
 */

package com.yahoo.ycsb.db;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;
import java.util.Vector;

import org.apache.log4j.Logger;
import com.tomting.orion.*;
import com.tomting.orion.connection.*;
import com.tomting.orion.connection.Helpers;
import com.yahoo.ycsb.*;


public class OrionClient extends DB {
	
	private final static Logger LOGGER = Logger.getLogger(OrionClient.class.getName());	
	
	public static final int Ok = 0;
	public static final int Error = -1;	
	private OCFI ocf = null;
	private OCI oc = null;
	

	
	public void init() throws DBException {
	    String hosts = getProperties().getProperty("hosts");
	    if (hosts == null) {
	      throw new DBException("Required property \"hosts\" missing for OrionClient");
	    }	
	    LOGGER.info(hosts);
	    
	    ocf = com.tomting.aries.Helpers.getSharedACF(Helpers.getSharedOCF (hosts), hosts);
	    oc = ocf.checkOut();
	}
	
	public void cleanup() throws DBException {

		ocf.checkIn(oc);
		ocf.close ();
	}	

	/**
	 * insert a key
	 */
	@Override
	public int insert(String table, String key, HashMap<String, ByteIterator> values) {
		boolean result = false;
		
		if (key == null || values == null) {
			LOGGER.fatal("null input");
			return Error;
		}
		

		ThrfL2st statement = OrionConnection.getStatement();
		statement.cVkey.sVmain = key;
		statement.cVkey.iVstate = iEstatetype.UPSERT;
		statement.cVmutable.sVtable = table.toUpperCase();
        
		Iterator<Entry<String, ByteIterator>> it = values.entrySet().iterator();
	    while (it.hasNext()) {
	        Map.Entry<String, ByteIterator> pairs = (Map.Entry<String, ByteIterator>)it.next();	
			ThrfL2cl cVcolumn = new ThrfL2cl ();
	        cVcolumn.cVvalue = new ThrfL2cv ();
	        cVcolumn.cVvalue.iVtype = iEcolumntype.STRINGTYPE;
	        cVcolumn.cVvalue.sVvalue = pairs.getValue().toString();
	        cVcolumn.sVcolumn = pairs.getKey(); 	        
	        statement.cVcolumns.add(cVcolumn);  	        
	        it.remove(); 
	    }		
		 
		try {			
			result = oc.runStatement(statement);			
		} catch (Exception e) {
			e.printStackTrace();
		}  
		return result ? Ok : Error;	
	}	
	
	/**
	 * single key read
	 */
	@Override
	public int read(String table, String key, Set<String> fields, HashMap<String, ByteIterator> result) {
		boolean returnedKeyslices = false;
	
		if (key == null) {
			LOGGER.fatal("null input");
			return Error;
		}		
		
		ThrfL2ks keyslice;
		ThrfL2qr query = OrionConnection.getQuery();
		query.cVmutable.sVtable = table.toUpperCase();	
		query.iVquery = iEquerytype.EXACTQUERY;
		query.cVkey_start = new ThrfLkey ();					
		query.cVkey_start.sVmain = key;		
		if (fields != null)
			for (String s : fields) {
		        ThrfL2cl cVcolumn = new ThrfL2cl ();
		        cVcolumn.sVcolumn = s;
		        query.cVselect.add(cVcolumn);  		
			}
        try {
        	ThrfL2qb queryReturn = oc.runQuery (query);
        	
        	returnedKeyslices = queryReturn.bVreturn;
        	if (returnedKeyslices) {
        		keyslice = queryReturn.cKeyslices.get(0);        		
        		for (ThrfL2cl column : keyslice.cVcolumns) {        			
        			result.put(column.sVcolumn, new StringByteIterator(column.cVvalue.sVvalue));
        		}
        	}
		} catch (Exception e){}        		
        return returnedKeyslices ? Ok : Error;		
	}
	
	/**
	 * update
	 */
	@Override	
	public int update(String table, String key, HashMap<String, ByteIterator> values) {
	    
		return insert(table, key, values);
	}	
	
	@Override
	public int scan(String table, String startkey, int recordcount, Set<String> fields,
			Vector<HashMap<String, ByteIterator>> result) {
		boolean returnedKeyslices = false;
	
		if (startkey == null) {
			LOGGER.fatal("null input");
			return Error;
		}		
		
		ThrfL2qr query = OrionConnection.getQuery();
		query.cVmutable.sVtable = table.toUpperCase();	
		query.iVquery = iEquerytype.RANGEQUERY;
		query.cVkey_start = new ThrfLkey ();					
		query.cVkey_start.sVmain = startkey;	
		query.iVcount = recordcount;
		if (fields != null)
			for (String s : fields) {
		        ThrfL2cl cVcolumn = new ThrfL2cl ();
		        cVcolumn.sVcolumn = s;
		        query.cVselect.add(cVcolumn);  		
			}
        try {
        	ThrfL2qb queryReturn = oc.runQuery (query);        	
        	
        	returnedKeyslices = queryReturn.bVreturn;
        	if (returnedKeyslices) {
        		for (ThrfL2ks keyslice : queryReturn.cKeyslices) {
        			HashMap<String, ByteIterator> row = new HashMap<String, ByteIterator> ();
	        		for (ThrfL2cl column : keyslice.cVcolumns) 
	        			row .put(column.sVcolumn, new StringByteIterator(column.cVvalue.sVvalue));
	        		result.add(row);
        		}
        	}
		} catch (Exception e){}   
        		
        return returnedKeyslices ? Ok : Error;	
	}

	/**
	 * delete a key
	 */
	@Override
	public int delete(String table, String key) {
		boolean result = false;
		
		if (key == null) {
			LOGGER.fatal("null input");
			return Error;
		}
		
		ThrfL2st statement = OrionConnection.getStatement();
		statement.cVkey.sVmain = key;
		statement.cVkey.iVstate = iEstatetype.DELTMB;
		statement.cVmutable.sVtable = table.toUpperCase();
        		 
		try {			
			result = oc.runStatement(statement);
		} catch (Exception e) {
		}  
		   				
        return result ? Ok : Error;	
	}		
	
	/**
	 * test client
	 * @param args
	 */
	public static void main(String[] args) {	
		OrionClient cli = new OrionClient ();
		Properties props = new Properties();
		props.setProperty("hosts", "orion:localhost:9001:DEFAULT");
	    cli.setProperties(props);

	    try {
	      cli.init();
	    } catch (Exception e) {
	      e.printStackTrace();
	      System.exit(0);
	    }
		
	    HashMap<String, ByteIterator> vals = new HashMap<String, ByteIterator>();
	    vals.put("age", new StringByteIterator("57"));
	    vals.put("middlename", new StringByteIterator("bradley"));
	    vals.put("favoritecolor", new StringByteIterator("blue"));
	    int res = cli.insert("USERTABLE", "BrianFrankCooper", vals);
	    System.out.println("Result of insert: " + res);	
	 	    
	    HashMap<String, ByteIterator> result = new HashMap<String, ByteIterator>();
	    HashSet<String> fields = new HashSet<String>();
	    fields.add("middlename");
	    fields.add("age");
	    fields.add("favoritecolor");
	    res = cli.read("usertable", "BrianFrankCooper", fields, result);
	    System.out.println("Result of read: " + res);
	    for (String s : result.keySet()) {
	      System.out.println("[" + s + "]=[" + result.get(s) + "]");
	    }	   	    
	    
	    res = cli.delete("usertable", "BrianFrankCooper");
	    System.out.println("Result of delete: " + res);	  		    
	    
	    result = new HashMap<String, ByteIterator>();
	    fields = new HashSet<String>();
	    fields.add("middlename");
	    fields.add("age");
	    fields.add("favoritecolor");
	    res = cli.read("usertable", "BrianFrankCooper", fields, result);
	    System.out.println("Result of read: " + res);
	    for (String s : result.keySet()) {
	      System.out.println("[" + s + "]=[" + result.get(s) + "]");
	    }	   	    
	    	    
	    try {
	    	cli.cleanup();
	    } catch (Exception e) {
	    	e.printStackTrace();
	    	System.exit(0);
	    }	    
	}
		
}
