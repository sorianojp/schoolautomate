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
  document.form_.print_pg.value = "";
	document.form_.pageAction.value = strAction;
	document.form_.isReloaded.value = "1";
	this.SubmitOnce('form_');
}

function PrepareToEdit(strIndex){
	document.form_.print_pg.value = "";
	document.form_.pageAction.value = "";
	document.form_.strIndex.value=strIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function PageAction(strAction,strIndex,strSupplierName){
	if(strAction == 0){
		var vProceed = confirm('Delete '+strSupplierName+' ?');
		if(vProceed){
			document.form_.print_pg.value = "";
			document.form_.pageAction.value = strAction;
			document.form_.strIndex.value = strIndex;
			this.SubmitOnce('form_');
		}
	}	else{
		document.form_.print_pg.value = "";
		document.form_.pageAction.value = strAction;
		document.form_.strIndex.value = strIndex;
		this.SubmitOnce('form_');
	}
}

function CancelClicked(){
	location = './suppliers.jsp';
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}
function updateState() {
	document.form_.print_pg.value = "";
	var loadPg = "./update_states.jsp?country="+document.form_.country[document.form_.country.selectedIndex].value+"&opner_form_name=form_&opner_form_field=state";
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateCity() {
	document.form_.print_pg.value = "";
	var loadPg = "./update_city.jsp?country=<%=WI.fillTextValue("country")%>&state=<%=WI.fillTextValue("state")%>&opner_form_name=form_&opner_form_field=city";
	var win=window.open(loadPg,"UpdateCity",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowOption(){
	if(document.form_.show_option.checked)
		document.form_.focus_area.value = '2';
	ReloadPage('','');
}
function FocusArea() {

	var pageNo = <%=WI.getStrValue(WI.fillTextValue("focus_area"),"1")%>
	eval('document.form_.area'+pageNo+'.focus()');
}

function ToggleReason() {
	var objReason = document.getElementById('inactive_reason');
	if(document.form_.supplier_status.selectedIndex == 0) {
		document.form_.inactive_hid.value = objReason.innerHTML;
		objReason.innerHTML = "";
	}
	else {
		//document.form_.inactive_hid.value = objReason.innerHTML;
		objReason.innerHTML = document.form_.inactive_hid.value;
	}
	
}

</script>
<%

	if(WI.fillTextValue("print_pg").equals("1")){%>
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
	Vector vEditInfo = new Vector();
	Vector vRetResult = new Vector();
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String[] astrSuppType = {"Individual","Company"};
	String[] astrPhoneType = {"Mobile","Home","Office"};
	int iSearchResult = 0;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("pageAction");
	String strChecked = null;
	String[] astrSortByName    = {"Supplier Code","Supplier name"};
	String[] astrSortByVal     = {"supplier_code","supplier_name"};

	if(strPageAction.length() > 0){
		if(SUP.operateOnSupplierInfo(dbOP,request,Integer.parseInt(strPageAction)) == null){
			strErrMsg = SUP.getErrMsg();
			//System.out.println("strErrMsg " + strErrMsg);
		}else{
			if(strPageAction.equals("1")){
				strErrMsg = "Saving Successful.";
				strPrepareToEdit = "";
			}else if(strPageAction.equals("2")){
				strErrMsg = "Update Successful.";
				strPrepareToEdit = "";
			}
		}

	}

	if (strPrepareToEdit.length() > 0){
		vEditInfo = SUP.operateOnSupplierInfo(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = SUP.getErrMsg();
 	}

	vRetResult = SUP.operateOnSupplierInfo(dbOP,request,4);
	if(vRetResult != null)
		iSearchResult =  SUP.getSearchCount();

String strIsInactive = null;

if(vEditInfo != null && vEditInfo.size() > 0)
	strIsInactive = (String)vEditInfo.elementAt(14);
else
	strIsInactive = WI.fillTextValue("supplier_status");
%>
<body bgcolor="#D2AE72" onLoad="javascript:FocusArea();ToggleReason()">
<form name="form_" method="post" action="suppliers.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          PURCHASING - SUPPLIERS : PROFILES PAGE ::::</strong></font></div></td>
    </tr>
    <tr valign="top" bgcolor="#FFFFFF">
      <td height="34" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<%if(WI.fillTextValue("goback").length() > 0) {%>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td colspan="2"><a href="<%=WI.fillTextValue("goback")%>"><img src="../../../images/go_back.gif" border="0"></a>
	  <font size="1">Go back to main page</font></td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td width="3%" height="25"><input type="text" name="area1" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
      <td width="17%">Type </td>
      <td width="29%">
<%if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
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
      <td width="51%" rowspan="2">
	  <label id="inactive_reason"></label>
	  Inactive Reason<br> 
<%if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(25);
else
	strTemp = WI.fillTextValue("_reason");
%>
	  	<textarea name="_reason" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onblur='style.backgroundColor="white"' rows="2" cols="50" style="font-size:10px;"><%=WI.getStrValue(strTemp)%></textarea>
	  
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Status</td>
      <td>
        <select name="supplier_status" onChange="ToggleReason();">
          <%if(strIsInactive.equals("0")){%>
          <option value="1">Active</option>
          <option value="0" selected>Inactive</option>
          <%}else{%>
          <option value="1" selected>Active</option>
          <option value="0">Inactive</option>
          <%}%>
        </select>		</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">Supplier Code: </td>
      <td height="25" colspan="2">
			<%if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
		  else
	  		strTemp = WI.fillTextValue("supplier_code");
	  %> <input name="supplier_code" type="text"  value="<%=strTemp%>" size="16" maxlength="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="15">&nbsp;</td>
      <td height="15">Supplier Name:</td>
      <td height="15" colspan="2">
			<%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(2);
	    else
	  		strTemp = WI.fillTextValue("supplier_name");
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
	  	 <%String strCountry = null; String strState = null;
		 if(vEditInfo != null && vEditInfo.size() > 0)
		    strCountry = (String)vEditInfo.elementAt(15);
		 else
			strCountry = WI.fillTextValue("country");
		 if(strCountry == null || strCountry.length() == 0)
			strCountry = dbOP.mapOneToOther("country","country_name","'" + "philippines" + "'","country_index","");
			 %>
		 <select name="country" onChange="javascript:ReloadPage('<%=WI.getStrValue(WI.fillTextValue("pageAction"),"5")%>','1');">
           <%=dbOP.loadCombo("COUNTRY_INDEX","COUNTRY_NAME"," FROM COUNTRY", strCountry, false)%> </select>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Province</td>
      <td height="25">
        <%
		   if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("isReloaded").length() < 1)
				strState = WI.getStrValue((String)vEditInfo.elementAt(16),"");
		   else if(WI.fillTextValue("state").length() > 0)
		 		strState = WI.fillTextValue("state");
		   else
		   		strState = "";
		%>
        <select name="state" onChange="javascript:ReloadPage('<%=WI.getStrValue(WI.fillTextValue("pageAction"),"5")%>','0');">
          <option value="">N/A</option>
		  <%
		  	strTemp2 = " FROM COUNTRY_STATE where COUNTRY_INDEX = "+strCountry;
		  %>
		  <%=dbOP.loadCombo("STATE_INDEX","STATE_NAME",strTemp2, strState, false)%>
        </select>
		<a href="javascript:updateState();">
			<img src="../../../images/update.gif" border="0"></a><font size="1">click to update list of Provinces</font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">City</td>
      <td height="25">
        <%if(vEditInfo != null && vEditInfo.size() > 0 && WI.fillTextValue("isReloaded").equals(""))
				strTemp = (String)vEditInfo.elementAt(17);
		  else if(WI.fillTextValue("city").length() > 0)
		 		strTemp = WI.fillTextValue("city");
		  else
		   		strTemp = "";
		%>
        <select name="city">
          <option value="">N/A</option>
     <%
	 	strTemp2 = " FROM COUNTRY_STATE_CITY where COUNTRY_INDEX = "+strCountry+WI.getStrValue(strState, " and state_index = ", "", " and state_index is null ");
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
        <%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(18);
			else
				strTemp = WI.fillTextValue("zipcode");
		%>
        <input name="zipcode" type="text" value="<%=strTemp%>" size="16" maxlength="12" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Address 1<strong></strong></td>
      <td height="25">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(19);
	    else
	  		strTemp = WI.fillTextValue("address_1");
	  %>
	  <input name="address_1" value="<%=strTemp%>" type="text" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Address 2<strong></strong></td>
      <td height="25">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(20),"");
	    else
	  		strTemp = WI.fillTextValue("address_2");
	  %>
	  <input name="address_2" value="<%=strTemp%>" type="text" size="68" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Address 3<strong></strong></td>
      <td height="25">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(21),"");
	    else
	  		strTemp = WI.fillTextValue("address_3");
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
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(4);
	    else
	  		strTemp = WI.fillTextValue("phone_1");
	  %> <input name="phone_1" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_1','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td width="40%" height="25">Type :
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(7);
	  	else
	  		strTemp = WI.fillTextValue("phone_type_1");
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

	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(5),"");
	  	else
	  		strTemp = WI.fillTextValue("phone_2");
	  %> <input name="phone_2" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_2','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td height="25">Type :
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(8);
	  	else
	  		strTemp = WI.fillTextValue("phone_type_2");
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
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(6),"");
	  	else
	  		strTemp = WI.fillTextValue("phone_3");
	  %> <input name="phone_3" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','phone_3','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
      <td height="25">Type :
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(9);
	  	else
	  		strTemp = WI.fillTextValue("phone_type_3");
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

	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(10),"");
	  	else
	  		strTemp = WI.fillTextValue("fax");
	  %> <input name="fax" value="<%=strTemp%>" onKeyUp="AllowOnlyIntegerExtn('form_','fax','-')" type="text" size="32" maxlength="32" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Email </td>
      <td height="25" colspan="2">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(22),"");
	  	else
	  		strTemp = WI.fillTextValue("email");
	  %> <input name="email" value="<%=strTemp%>" type="text" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Website</td>
      <td height="25" colspan="2">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(23),"");
	  	else
	  		strTemp = WI.fillTextValue("website");
	  %> <input name="website" value="<%=strTemp%>" type="text" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'>      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Contact Person</td>
      <td height="25" colspan="2">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(12);
	  	else
	  		strTemp = WI.fillTextValue("con_person");
	  %> <input name="con_person" value="<%=strTemp%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Salutation</td>
      <td height="25" colspan="2">

	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = WI.getStrValue((String)vEditInfo.elementAt(11),"");
	  	else
	  		strTemp = WI.fillTextValue("salutation");
	  %> <input name="salutation" value="<%=strTemp%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Position</td>
      <td height="25" colspan="2">
	  <%if(vEditInfo != null && vEditInfo.size() > 0)
	  		strTemp = (String)vEditInfo.elementAt(13);
	  	else
	  		strTemp = WI.fillTextValue("position");
	  %> <input name="position" value="<%=WI.getStrValue(strTemp)%>" type="text" size="64" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><strong><u>REMARK</u></strong></td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
<%if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(24);
else
	strTemp = WI.fillTextValue("remarks");
%>
	  <textarea name="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onblur='style.backgroundColor="white"' rows="4" cols="70"><%=WI.getStrValue(strTemp)%></textarea>
	  </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="40">&nbsp;</td>
      <td height="40">&nbsp;</td>
      <td height="40">&nbsp;</td>
      <td height="40" colspan="2"><font size="1">
	  <%if(vEditInfo != null && vEditInfo.size() > 0){%>
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
			<%
				if(WI.fillTextValue("show_option").length() > 0)
					strChecked = " checked";
				else
					strChecked = "";
			%>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="5"><input type="checkbox" name="show_option" value="1" <%=strChecked%> onClick="ShowOption();">
Show View Options</td>
    </tr>
		<%if(WI.fillTextValue("show_option").length() > 0){%>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="5"><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td  width="3%" height="25">&nbsp;</td>
          <td colspan="3">
		  <input type="checkbox" name="show_inactive" value="checked" <%=WI.fillTextValue("show_inactive")%>>
		  Show Only In-active Suppliers </td>
          <td width="8%">&nbsp;</td>
        </tr>
        <tr>
          <td height="25">&nbsp;</td>
          <td width="11%">&nbsp;</td>
          <td width="28%">&nbsp;</td>
          <td width="50%">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="19">&nbsp;</td>
          <td>&nbsp;</td>
          <td colspan="2">&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="25">&nbsp;</td>
          <td>&nbsp;</td>
          <td colspan="2"><font size="1">
            <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.focus_area.value = '2';javascript:ReloadPage('','');">
          </font></td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td height="18">&nbsp;</td>
          <td>&nbsp;</td>
          <td colspan="2"><strong><font size="2">
            <input type="text" name="area2" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;">
          </font></strong></td>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
		<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
	int iPageCount = iSearchResult/SUP.defSearchSize;
	if(iSearchResult % SUP.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr bgcolor="#FFFFFF">
      <td height="10" colspan="2" align="right"><font size="2">Jump To page:
          <select name="jumpto" onChange="document.form_.focus_area.value = '3';ReloadPage('','');">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
      </font></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF SUPPLIERS</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="8" class="thinborder"><strong>TOTAL SUPPLIER(S) : <%=iSearchResult%></strong></td>
    </tr>
    <tr style="font-weight:bold" align="center">
      <td width="8%" height="25" class="thinborder">SUPPLIER CODE </td>
      <td width="22%" class="thinborder">SUPPLIER NAME</td>
      <td width="5%" class="thinborder">TYPE</td>
      <td width="20%" class="thinborder">ADDRESS</td>
      <td width="13%" class="thinborder">CONTACT NOS.</td>
      <td width="20%" class="thinborder">CONTACT PERSON</td>
      <td width="6%" class="thinborder">EDIT</td>
      <td width="6%" class="thinborder">DELETE</td>
    </tr>
    <%
		String strPosition = null;
		for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=26){%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(iLoop+1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(iLoop+2)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+3);
				strTemp = astrSuppType[Integer.parseInt(WI.getStrValue(strTemp,"0"))];
			%>
      <td class="thinborder"><%=strTemp%></td>
	  
	  <td class="thinborder">&nbsp;</td>
		<%
				strTemp2 = (String)vRetResult.elementAt(iLoop+7);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp = WI.getStrValue((String)vRetResult.elementAt(iLoop+4), strTemp2 + " :<br>","<br>","");
				strTemp2 = (String)vRetResult.elementAt(iLoop+8);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+5),strTemp2 + " :<br>","<br>","");
				strTemp2 = (String)vRetResult.elementAt(iLoop+9);
				strTemp2 = astrPhoneType[Integer.parseInt(strTemp2)];
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+6),strTemp2 + " :<br>","<br>","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+10),"Fax :<br>","<br>","");
		%>
      <td class="thinborder"><%=strTemp%></td>
			<%
//            vEditInfo.addElement(WI.getStrValue(rs.getString(13),
//                WI.getStrValue(rs.getString(12),"","&nbsp;",""),
//                WI.getStrValue(rs.getString(14)," <br>(",")",""), ""));//CONTACT_PERSON[5]

				strPosition = WI.getStrValue((String)vRetResult.elementAt(iLoop+13),"(",")","");// position
				strTemp = (String)vRetResult.elementAt(iLoop+11); // salutation
				strTemp = WI.getStrValue(strTemp,"","&nbsp;","");
				strTemp2 = (String)vRetResult.elementAt(iLoop+12); // Contact person
				strTemp2 = WI.getStrValue(strTemp2, strTemp, "<br>" +strPosition,"&nbsp;");

			%>
      <td class="thinborder"><%=strTemp2%></td>
      <td class="thinborder"><div align="center"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(iLoop)%>');"><img src="../../../images/edit.gif" border="0"></a></div></td>
      <td class="thinborder"><div align="center"><a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(iLoop)%>','<%=(String)vRetResult.elementAt(iLoop+2)%>');"><img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25"><input type="text" name="area3" readonly="yes" size="2" style="background-color:#FFFFFF;border-width: 0px;"></td>
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

    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
		<%}%>
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="<%=WI.fillTextValue("strIndex")%>">
  <input type="hidden" name="isReloaded" value="">
  <input type="hidden" name="print_pg" value="">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="focus_area">

  <!-- called from parent page.. -->
  <input type="hidden" name="goback" value="<%=WI.fillTextValue("goback")%>">
  <input type="hidden" name="inactive_hid" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
