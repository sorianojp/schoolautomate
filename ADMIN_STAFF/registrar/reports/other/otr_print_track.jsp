<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//// - all about ajax..
var strPosition = ''; 
function AjaxMapName(strPos) {
		strPosition = strPos;
		
		var strCompleteName;
		var objCOAInput;

		if(strPos == '1') {
			objCOAInput = document.getElementById("coa_info");
			strCompleteName = document.form_.stud_id.value;
		}
		else {
			objCOAInput = document.getElementById("coa_info2");
			strCompleteName = document.form_.printed_by.value;
		}

		if(strCompleteName.length < 2)
			return;

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		if(strPos == '1')
			strPos = '';
		else	
			strPos = "&is_faculty=1";
			
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1"+strPos+"&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	if(strPosition == '1')
		document.form_.stud_id.value = strID;
	else	
		document.form_.printed_by.value = strID;
	
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(strPosition == '1')
		document.getElementById("coa_info").innerHTML = "";
	else	
		document.getElementById("coa_info2").innerHTML = "";
}

function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	window.print();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
		//may be called from registrar.
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
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
Vector vRetResult = new Vector();
if(WI.fillTextValue("show_result").equals("1")) {
	///search here.. 
	String strSQLQuery = "";
	String strStudIndex = null;
	String strPrintedBy = null;
	
	if(WI.fillTextValue("stud_id").length() > 0) 
		strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	if(WI.fillTextValue("printed_by").length() > 0) 
		strPrintedBy = dbOP.mapUIDToUIndex(WI.fillTextValue("printed_by"));
	if(WI.fillTextValue("date_fr").length() > 0) {
		if(WI.fillTextValue("date_to").length() > 0) {
			strSQLQuery = " and track_printing.date_printed between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"))+"' and '"+
							ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"))+"'";
		}
		else
			strSQLQuery = " and track_printing.date_printed = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"))+"'";
	}
	if(strStudIndex != null)
		strSQLQuery += " and track_printing.stud_index = "+strStudIndex;
	if(strPrintedBy != null)
		strSQLQuery += " and track_printing.printed_by = "+strPrintedBy;
	if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("ignore_sy").length() == 0) {
		strSQLQuery += " and exists (select cur_hist_index from stud_curriculum_hist where is_valid =1 and sy_from = "+WI.fillTextValue("sy_from") +" and semester = "+
						WI.fillTextValue("semester")+" and user_index = stud_index)";
	}
	strSQLQuery = "select studID.id_number, studID.fname, studID.mname, studID.lname, date_Printed, printedBy.id_number, printedBy.fname, printedBy.mname, printedBy.lname,note_ from track_printing "+
				"join user_table as studID on (studID.user_index = stud_index) "+
				"join user_table as printedBy on (printedBy.user_index = printed_by) "+
				" where print_module = 3 "+strSQLQuery+" order by studID.lname, studID.fname";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));//[0]  id_number
		vRetResult.addElement(WI.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1]  name.
		vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(5)));//[2]  date_printed
		vRetResult.addElement(rs.getString(6));//[3]  Printed By
		vRetResult.addElement(WI.formatName(rs.getString(7), rs.getString(8), rs.getString(9), 4));//[4]  Printed by Name..
		vRetResult.addElement(rs.getString(10));//[5] Note.
	}
	rs.close();
	
}
String[] astrConvertTerm = {"Summer","1st Term","2nd Term","3rd Term"};


boolean bolShowHeading = strSchCode.startsWith("EAC");
bolShowHeading = true;
%>
<body>
<form name="form_" action="./otr_print_track.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: OTR PRINT INFORMATION ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font style="font-size:16px; font-weight:bold; color:#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="13%" height="25">SY/TERM</td>
      <td width="86%" height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))  
			strTemp = "1";
	
		  if(strTemp.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="ignore_sy" value="selected" <%=WI.fillTextValue("ignore_sy")%>> Ignore SY-Term</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID </td>
      <td height="25" colspan="2">
	  <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:450px;"></label>
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Date Printed </td>
      <td height="25" colspan="2">
<input name="date_fr"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        &nbsp;&nbsp;To
        <input name="date_to"  type="text" size="11" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:10px;">
      <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Printed By </td>
      <td height="25" colspan="2">
		<input name="printed_by" type="text" size="16" value="<%=WI.fillTextValue("printed_by")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('2');">
	  <label id="coa_info2" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:450px;"></label>
  	  </td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> 
	  <input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'">
<%if(bolShowHeading){%>		
		Rows per Page to Print : 
<%
int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg"), "45"));
%>		
		<select name="rows_per_pg">
			<%for(int i =25; i < 75; ++i) {
				if(iDefVal == i)
					strTemp = "selected";
				else	
					strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=i%></option>
			<%}%>
		</select>
<%}%>	  </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0 && false) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>Print Page</td>
    </tr>
<%}%>
  </table>


<%
if(vRetResult != null && vRetResult.size() > 0) {
	int iDefVal = 45;
	if(WI.fillTextValue("rows_per_pg").length()> 0) 
		iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
		
	int iTotalCount = vRetResult.size()/6;
	int iTotalPage  = iTotalCount/iDefVal;
	if(iTotalCount % iDefVal > 0)
		++iTotalPage;
	int iPageNo = 1;
	int iRowPrinted = 0;
	iTotalCount = 0;	
	while(vRetResult.size() > 0) {
	
	if(iPageNo > 1 && bolShowHeading) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%}if(bolShowHeading){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td style="font-size:9px;">Date time Printed: <%=WI.getTodaysDateTime()%></td>
		  <td style="font-size:9px;" align="right">Page <%=iPageNo++%> of <%=iTotalPage%></td>
		</tr>
		<tr>
			<td align="center" colspan="2"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
			<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>
			<br>&nbsp;	  </td>
		</tr>
  </table><%}%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0"<%if(bolShowHeading){%>class="thinborder"<%}else{%><%}%>>
		<tr style=" font-weight:bold"> 
		  <td height="25" width="5%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Count</td>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Student ID </td>
		  <td width="20%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Student Name </td>
		  <td width="10%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Date Printed </td>
		  <td width="35%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">OTR Remark </td>
		  <td width="20%" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>">Printed By  </td>
		</tr>
	<%while(vRetResult.size() > 0) {
		if(bolShowHeading) {
			if(++iRowPrinted > iDefVal) {
				iRowPrinted = 0;
				break;
			}
		}
		%>    
		<tr>
		  <td height="25" class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=++iTotalCount%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(0)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(1)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(2)%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=WI.getStrValue((String)vRetResult.elementAt(5), "&nbsp;")%></td>
		  <td class="<%if(!bolShowHeading){%>thinborderNONE<%}else{%>thinborder<%}%>"><%=vRetResult.elementAt(4)%></td>
		</tr>
		<%
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		}%>
	  </table>
	<%}
}%>
  <input type="hidden" name="show_result">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>