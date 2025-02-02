<%@ page language="java" import="utility.*,java.util.Vector,purchasing.Supplier,purchasing.Country " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Suppliers</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strAction,strCountry){
	if(strCountry == 1){
		document.form_.state.value = "";
		document.form_.city.value = "";
	}	
    document.form_.printClicked.value = "";
	document.form_.pageAction.value = strAction;
	document.form_.isReloaded.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strIndex,strSupplierName){
	if(strAction == 0){
		var vProceed = confirm('Delete '+strSupplierName+' ?');
		if(vProceed){
			document.form_.printClicked.value = "";
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}
	}
	else{
		document.form_.printClicked.value = "";
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');
	}
}
function CancelClicked(){
	location = './suppliers.jsp';
}
function PrintPage(){
	document.form_.printClicked.value = "1";
	this.SubmitOnce('form_');
}
function updateState() {
	document.form_.printClicked.value = "";
	var loadPg = "./update_states.jsp?country=<%=WI.fillTextValue("country")%>&opner_form_name=form_&opner_form_field=state";
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateCity() {
	document.form_.printClicked.value = "";
	var loadPg = "./update_city.jsp?country=<%=WI.fillTextValue("country")%>&state=<%=WI.fillTextValue("state")%>&opner_form_name=form_&opner_form_field=city";
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	
	if(WI.fillTextValue("printClicked").equals("1")){%>
		<jsp:forward page="suppliers_print.jsp"/>
	<%return;}		
	
//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-SUPPLIERS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	DBOperation dbOP = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-SUPPLIERS-Suppliers","suppliers.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
		
	Supplier SUP = new Supplier();
	new Country(dbOP);
	Vector vRetResult = new Vector();
	Vector vRetSuppliers = new Vector();
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

	if(WI.fillTextValue("pageAction").length() > 0){
		vRetResult = SUP.operateOnSupplierInfo(dbOP,request,
					 	Integer.parseInt(WI.getStrValue(WI.fillTextValue("pageAction"),"4")));	    
		if(vRetResult == null)
			strErrMsg = SUP.getErrMsg();
		else if(vRetResult != null && !((WI.fillTextValue("pageAction").equals("3") || WI.fillTextValue("pageAction").equals("5"))))
			strErrMsg = "Operation Successful.";			
	}	
	
	vRetSuppliers = SUP.operateOnSupplierInfo(dbOP,request,4);
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post" action="suppliers.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PURCHASING - SUPPLIERS : PROFILES PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top" bgcolor="#FFFFFF"> 
      <td height="34" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Type </td>
      <td width="29%">
        <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(3);
		else
			strTemp = WI.fillTextValue("supplier_type");
	  %>
        <select name="supplier_type">
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>Individual</option>
          <option value="1">Company</option>
          <%}else{%>
          <option value="0">Individual</option>
          <option value="1" selected>Company</option>
          <%}%>
        </select></td>
      <td width="51%">Status 
        <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(14);
		else
			strTemp = WI.fillTextValue("supplier_status");
	  %>
        <select name="supplier_status">
          <%if(strTemp.equals("0")){%>
          <option value="1">Active</option>
          <option value="0" selected>Inactive</option>
          <%}else{%>
          <option value="1" selected>Active</option>
          <option value="0">Inactive</option>
          <%}%>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">Supplier Code: </td>
      <td height="25" colspan="2"> <%if(WI.fillTextValue("pageAction").equals("3"))
			strTemp = (String)vRetResult.elementAt(1);	
		  else if(WI.fillTextValue("supplier_code").length() > 0)
	  		strTemp = WI.fillTextValue("supplier_code");
	  	  else
	  		strTemp = "";
	  %> <input name="supplier_code" type="text"  value="<%=strTemp%>" size="16" maxlength="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15">&nbsp;</td>
      <td height="15">Supplier Name:</td>
      <td height="15" colspan="2"> <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(2);
	    else if(WI.fillTextValue("supplier_name").length() > 0)
	  		strTemp = WI.fillTextValue("supplier_name");
	    else
	  		strTemp = "";
	  %> <input name="supplier_name" type="text" value="<%=strTemp%>" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>ADDRESS</u></strong></td>
      <td width="80%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Country</td>
      <td height="25">
	  	 <%if(WI.fillTextValue("pageAction").equals("3") && WI.fillTextValue("isReloaded").equals(""))
		        strTemp = (String)vRetResult.elementAt(15); 
		   else if(WI.fillTextValue("country").length() > 0)
		 		strTemp = WI.fillTextValue("country");
		   else
		   		strTemp = dbOP.mapOneToOther("country","country_name","'" + "philippines" + "'","country_index","");
		 %>
		 <select name="country" onChange="javascript:ReloadPage('<%=WI.getStrValue(WI.fillTextValue("pageAction"),"5")%>','1');">
          <option value="">Select Country</option>
          <%=dbOP.loadCombo("COUNTRY_INDEX","COUNTRY_NAME"," FROM COUNTRY", strTemp, false)%> </select>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Province</td>
      <td height="25">	  
        <% 
		   if(WI.fillTextValue("pageAction").equals("3") && WI.fillTextValue("isReloaded").length() < 1)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(16),"");
		   else if(WI.fillTextValue("state").length() > 0)
		 		strTemp = WI.fillTextValue("state");
		   else
		   		strTemp = "";
		%>
        <select name="state" onChange="javascript:ReloadPage('<%=WI.getStrValue(WI.fillTextValue("pageAction"),"5")%>','0');">
          <option value="">N/A</option>
		  <%if(vRetResult != null && WI.fillTextValue("pageAction").equals("3") && WI.fillTextValue("isReloaded").equals(""))
		  		strTemp2 = " FROM COUNTRY_STATE where COUNTRY_INDEX = "+(String)vRetResult.elementAt(15);		  	
			else{			
				if(WI.fillTextValue("country").length() > 0 || (WI.fillTextValue("country").length() > 0 && WI.fillTextValue("pageAction").equals("3")))
					strTemp2 = " FROM COUNTRY_STATE where COUNTRY_INDEX = "+WI.fillTextValue("country");
				else
					strTemp2 = " FROM COUNTRY_STATE where COUNTRY_INDEX = (select country_index from country where country_name = 'philippines')";				
			}%>		  
		  <%=dbOP.loadCombo("STATE_INDEX","STATE_NAME",strTemp2, strTemp, false)%>
        </select> 
		<a href="javascript:updateState();">
			<img src="../../../images/update.gif" border="0"></a><font size="1">click to update list of Provinces</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">City</td>
      <td height="25"> 
        <%if(WI.fillTextValue("pageAction").equals("3") && WI.fillTextValue("isReloaded").equals(""))
				strTemp = (String)vRetResult.elementAt(17);
		  else if(WI.fillTextValue("city").length() > 0)
		 		strTemp = WI.fillTextValue("city");
		  else
		   		strTemp = "";		
		%>
        <select name="city">
          <option value="">N/A</option>
          <%if(vRetResult != null && WI.fillTextValue("pageAction").equals("3") && WI.fillTextValue("isReloaded").equals("")){
		  		if(WI.getStrValue((String)vRetResult.elementAt(16),"").length() > 0)
					strTemp2 = " FROM COUNTRY_STATE_CITY where STATE_INDEX = "+(String)vRetResult.elementAt(16);
				else
					strTemp2 = " FROM COUNTRY_STATE_CITY where COUNTRY_INDEX = "+(String)vRetResult.elementAt(15)+" and STATE_INDEX is null";		  	
			}
		  	else{
				if(WI.fillTextValue("state").length() > 0 && !WI.fillTextValue("state").equals("N/A") && !WI.fillTextValue("state").equals("null"))
					strTemp2 = " FROM COUNTRY_STATE_CITY where COUNTRY_INDEX = "+WI.fillTextValue("country")+" and STATE_INDEX = "+WI.fillTextValue("state");					
				else if(WI.fillTextValue("country").length() > 0)
					strTemp2 = " FROM COUNTRY_STATE_CITY where COUNTRY_INDEX = "+WI.fillTextValue("country")+" and STATE_INDEX is null";					
				else
					strTemp2 = " FROM COUNTRY_STATE_CITY where COUNTRY_INDEX = 0";										
			}
			%>		  
          <%=dbOP.loadCombo("CITY_INDEX","CITY_NAME",strTemp2, strTemp, false)%> 
        </select>
		<a href="javascript:updateCity();"><img src="../../../images/update.gif" border="0"></a><font size="1">click to update list of Cities</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Zip Code</td>
      <td height="25"> 
        <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(18);
	    else if(WI.fillTextValue("zipcode").length() > 0)
	  		strTemp = WI.fillTextValue("zipcode");
	    else
	  		strTemp = "";
	  %>
        <input name="zipcode" type="text" value="<%=strTemp%>" size="16" maxlength="12" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Address 1<strong></strong></td>
      <td height="25">
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(19);
	    else if(WI.fillTextValue("address_1").length() > 0)
	  		strTemp = WI.fillTextValue("address_1");
	    else
	  		strTemp = "";
	  %>
	  <input name="address_1" value="<%=strTemp%>" type="text" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Address 2<strong></strong></td>
      <td height="25">
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(20),"");
	    else if(WI.fillTextValue("address_2").length() > 0)
	  		strTemp = WI.fillTextValue("address_2");
	    else
	  		strTemp = "";
	  %>
	  <input name="address_2" value="<%=strTemp%>" type="text" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Address 3<strong></strong></td>
      <td height="25">
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(21),"");
	    else if(WI.fillTextValue("address_3").length() > 0)
	  		strTemp = WI.fillTextValue("address_3");
	    else
	  		strTemp = "";
	  %>
	  <input name="address_3" value="<%=strTemp%>" type="text" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><u>CONTACT INFO</u></strong></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Phone #1<strong></strong></td>
      <td width="40%" height="25"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(4);
	    else if(WI.fillTextValue("phone_1").length() > 0)
	  		strTemp = WI.fillTextValue("phone_1");	  
	    else
	  		strTemp = "";
	  %> <input name="phone_1" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_1','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td width="40%" height="25">Type :
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(7);
	  	else if(WI.fillTextValue("phone_type_1").length() > 0)
	  		strTemp = WI.fillTextValue("phone_type_1");
	  	else
	  		strTemp = "";
	  %>
	  	<select name="phone_type_1">		
          <option value="0">MOBILE</option>
		  <%if(strTemp.equals("1")){%>
		  <option value="1" selected>HOME</option>
		  <option value="2">OFFICE</option>
		  <%}else if(strTemp.equals("2")){%>
		  <option value="1">HOME</option>
		  <option value="2" selected>OFFICE</option>
		  <%}else{%>
		  <option value="1">HOME</option>
		  <option value="2">OFFICE</option>
		  <%}%>           
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Phone #2<strong></strong></td>
      <td height="25"> 
	  
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(5),"");
	  	else if(WI.fillTextValue("phone_2").length() > 0)
	  		strTemp = WI.fillTextValue("phone_2");
	  	else
	  		strTemp = "";
	  %> <input name="phone_2" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_2','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td height="25">Type :
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(8);
	  	else if(WI.fillTextValue("phone_type_2").length() > 0)
	  		strTemp = WI.fillTextValue("phone_type_2");
	  	else
	  		strTemp = "";
	  %>
	  	<select name="phone_type_2">		
          <option value="0">MOBILE</option>
		  <%if(strTemp.equals("1")){%>
		  <option value="1" selected>HOME</option>
		  <option value="2">OFFICE</option>
		  <%}else if(strTemp.equals("2")){%>
		  <option value="1">HOME</option>
		  <option value="2" selected>OFFICE</option>
		  <%}else{%>
		  <option value="1">HOME</option>
		  <option value="2">OFFICE</option>
		  <%}%>           
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Phone #3<strong></strong></td>
      <td height="25"> 	  
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(6),"");
	  	else if(WI.fillTextValue("phone_3").length() > 0)
	  		strTemp = WI.fillTextValue("phone_3");
	  	else
	  		strTemp = "";
	  %> <input name="phone_3" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_3','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td height="25">Type :
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(9);
	  	else if(WI.fillTextValue("phone_type_3").length() > 0)
	  		strTemp = WI.fillTextValue("phone_type_3");
	  	else
	  		strTemp = "";
	  %>
	  	<select name="phone_type_3">		
          <option value="0">MOBILE</option>
		  <%if(strTemp.equals("1")){%>
		  <option value="1" selected>HOME</option>
		  <option value="2">OFFICE</option>
		  <%}else if(strTemp.equals("2")){%>
		  <option value="1">HOME</option>
		  <option value="2" selected>OFFICE</option>
		  <%}else{%>
		  <option value="1">HOME</option>
		  <option value="2">OFFICE</option>
		  <%}%>           
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Fax #</td>
      <td height="25" colspan="2"> 
	  
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(10),"");
	  	else if(WI.fillTextValue("fax").length() > 0)
	  		strTemp = WI.fillTextValue("fax");
	  	else
	  		strTemp = "";
	  %> <input name="fax" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','fax','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Email </td>
      <td height="25" colspan="2"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(22),"");	
	  	else if(WI.fillTextValue("email").length() > 0)
	  		strTemp = WI.fillTextValue("email");
	  	else
	  		strTemp = "";
	  %> <input name="email" value="<%=strTemp%>" type="text" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Website</td>
      <td height="25" colspan="2"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(23),"");
	  	else if(WI.fillTextValue("website").length() > 0)
	  		strTemp = WI.fillTextValue("website");
	  	else
	  		strTemp = "";
	  %> <input name="website" value="<%=strTemp%>" type="text" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Contact Person</td>
      <td height="25" colspan="2"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(12);
	  	else if(WI.fillTextValue("con_person").length() > 0)
	  		strTemp = WI.fillTextValue("con_person");
	  	else
	  		strTemp = "";
	  %> <input name="con_person" value="<%=strTemp%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Salutation</td>
      <td height="25" colspan="2"> 
	  
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = WI.getStrValue((String)vRetResult.elementAt(11),"");
	  	else if(WI.fillTextValue("salutation").length() > 0)
	  		strTemp = WI.fillTextValue("salutation");
	  	else
	  		strTemp = "";
	  %> <input name="salutation" value="<%=strTemp%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Position</td>
      <td height="25" colspan="2"> 
	  <%if(WI.fillTextValue("pageAction").equals("3"))
	  		strTemp = (String)vRetResult.elementAt(13);
	  	else if(WI.fillTextValue("position").length() > 0)
	  		strTemp = WI.fillTextValue("position");
	  	else
	  		strTemp = "";
	  %> <input name="position" value="<%=WI.getStrValue(strTemp)%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="40">&nbsp;</td>
      <td height="40">&nbsp;</td>
      <td height="40">&nbsp;</td>
      <td height="40" colspan="2"><font size="1">
	  <%if(WI.fillTextValue("pageAction").equals("3") || (WI.fillTextValue("pageAction").equals("2") && vRetResult == null)){%>
	    	<a href="javascript:PageAction(2,'<%=WI.fillTextValue("strIndex")%>','')">
   		    <img src="../../../images/edit.gif" border="0"></a>click to edit event&nbsp; 
	  <%}else{%>
   	        <a href="javascript:PageAction(1,'','');"> 
            <img src="../../../images/save.gif" border="0"></a>click to save entries&nbsp;			
	  <%}%>
        <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a>click to cancel/clear entries 
		</font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" dwcopytype="CopyTableRow">
  <%if(vRetSuppliers != null){
  		if(vRetSuppliers.size() > 1){%>
    <tr> 
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF SUPPLIERS</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="8" class="thinborder"><strong>TOTAL SUPPLIER(S) : <%=(String)vRetSuppliers.elementAt(0)%></strong></td>
    </tr>
    <tr> 
      <td width="9%" height="25" class="thinborder"><div align="center"><strong>SUPPLIER CODE </strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong>SUPPLIER NAME</strong></div></td>
      <td width="5%" class="thinborder"><div align="center"><strong>TYPE</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>CONTACT NOS.</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>CONTACT PERSON</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>A/P BALANCE</strong></div></td>
      <td colspan="2" class="thinborder"><div align="center"><strong>OPTIONS</strong></div></td>
    </tr>
    <%for(int iLoop = 1;iLoop < vRetSuppliers.size();iLoop+=6){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(String)vRetSuppliers.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vRetSuppliers.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vRetSuppliers.elementAt(iLoop+5)%></div></td>
      <td class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder"><div align="center"><a href="javascript:PageAction(3,'<%=(String)vRetSuppliers.elementAt(iLoop)%>','');"><img src="../../../images/edit.gif" border="0"></a></div></td>
      <td width="9%" class="thinborder"><div align="center"><a href="javascript:PageAction(0,'<%=(String)vRetSuppliers.elementAt(iLoop)%>','<%=(String)vRetSuppliers.elementAt(iLoop+2)%>');"><img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center"> Number of Suppliers Per 
          Page: 
          <select name="num_stud_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
	  
	  <a href="javascript:PrintPage();">	  
	  <img src="../../../images/print.gif" border="0"></a><font size="1">click to print list</font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
	<%}}%>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="isReloaded" value="">
  <input type="hidden" name="printClicked" value="">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>
