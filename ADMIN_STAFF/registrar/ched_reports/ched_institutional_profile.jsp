<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDInstProfile, chedReport.CHEDCreateTable"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	
	
	if (WI.fillTextValue("print_page").equals("1")) {%>
	<jsp:forward page="./ched_institutional_profile_print.jsp" />
<%
	 return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Institutional Profile</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">

function SaveRecord(strIndex){
	document.form_.page_action.value="1";
	document.form_.info_index.value = strIndex;
	document.form_.print_page.value="0";
	this.SubmitOnce("form_");
}

function PrintPage(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function UpdateXNames() {
	var pgLoc = "./ched_inst_profile_x_names.jsp?parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=600,height=300,top=45,left=345,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_b_c.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


new CHEDCreateTable().createCHEDTables(dbOP);
Vector vRetResult = null;
Vector vFormerNames = null;
CHEDInstProfile cr = new CHEDInstProfile();


if (WI.fillTextValue("page_action").equals("1")){
	if (cr.operateOnChedInstProfile(dbOP,request,1) != null)
		strErrMsg = " Institutional Profile saved successfully";
	else
		strErrMsg =cr.getErrMsg();	
}
	vRetResult = cr.operateOnChedInstProfile(dbOP,request,3);
	
	if (vRetResult != null && vRetResult.size() > 0) 
		vFormerNames = (Vector)vRetResult.elementAt(0);
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./ched_institutional_profile.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>INSTITUTIONAL 
          PROFILE </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <tr> 
      <td width="26%" height="25" class="body_font">&nbsp;Academic Year</td>
      <td width="74%"> <%=(String)request.getSession(false).getAttribute("cur_sch_yr_from")%> to <%=(String)request.getSession(false).getAttribute("cur_sch_yr_to")%> </td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Name of Institution</td>
      <td>&nbsp;<%=SchoolInformation.getSchoolName(dbOP,false,false)%></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Unique Institutional Identifier</td>
	  <% strTemp = WI.fillTextValue("unique_inst_id");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(1),"NA");
	  %>
      <td> <input name="unique_inst_id" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Institutional Form of Ownership 
      </td>
	  <% strTemp = WI.fillTextValue("ownership_type_index");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
	  %>	  
      <td> <select name="ownership_type_index">
          <option value="">Select a ownership type</option>
          <%=dbOP.loadCombo("OWNERSHIP_TYPE_INDEX","OWNERSHIP_TYPE"," from CHED_OWNERSHIP_TYPE where IS_DEL=0 order by OWNERSHIP_CODE asc", strTemp, false)%> </select> </td>
    </tr>
    <tr bgcolor="#FEF7F5"> 
      <td height="18" colspan="2" class="body_font">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="2" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" class="body_font">X - Coordinate</td>
      <% strTemp = WI.fillTextValue("x_coord");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(22));
	  %>      
	  <td class="body_font">  
	  <input name="x_coord" type="text" size="24" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="body_font">Y - Coordinate</td>
      <% strTemp = WI.fillTextValue("y_coord");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(23));
	  %>	  
      <td><input name="y_coord" type="text" size="24" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="20%" height="25" class="body_font">&nbsp;Address&nbsp;Street</td>
      <% strTemp = WI.fillTextValue("add_street");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(5),"NA");
	  %>
      <td colspan="3"> <input name="add_street" type="text" size="48" maxlength="64" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="26" class="body_font">&nbsp;District / &nbsp;Municipality </td>
      <% strTemp = WI.fillTextValue("district_municipality");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
	  %>
      <td width="32%"><input name="district_municipality" type="text" size="24" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
      <td width="16%" class="body_font">&nbsp;Province / City</td>
      <% strTemp = WI.fillTextValue("province");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
	  %>
      <td width="32%"><input name="province" type="text" size="24" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Region</td>
      <% strTemp = WI.fillTextValue("region");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
	  %>
      <td><input name="region" type="text" size="24" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="body_font">&nbsp;Postal or Zip Code</td>
      <% strTemp = WI.fillTextValue("zip_code");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
	  %>
      <td><input name="zip_code" type="text" size="5" maxlength="5" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FEF7F5"> 
      <td height="18" colspan="4" class="body_font">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="25%" height="25" class="body_font">&nbsp;Institutional Telephone</td>
	  <% strTemp = WI.fillTextValue("inst_tel");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
	  %>
      <td width="75%"><input name="inst_tel" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(include Area Code)</font></td>
    </tr>
    <tr> 
      <td height="18" class="body_font">&nbsp;Institutional Fax No. </td>
	  <% strTemp = WI.fillTextValue("inst_fax");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(11));
	  %>
      <td><input name="inst_fax" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(include Area Code)</font></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Institutional Head's Telephone </td>
	  <% strTemp = WI.fillTextValue("inst_head_tel");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(12));
	  %>
      <td><input name="inst_head_tel" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font size="1">(include Area Code)</font></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Institutional Website</td>
	  <% strTemp = WI.fillTextValue("inst_website");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(13));
	  %>
	  <td><input name="inst_website" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font">&nbsp;Institutional E-mail Address</td>
	  <% strTemp = WI.fillTextValue("inst_email");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
	  %>
	  <td><input name="inst_email" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#FEF7F5"> 
      <td height="18" bgcolor="#FEF7F5" class="body_font">&nbsp;</td>
      <td bgcolor="#FEF7F5">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" class="body_font"><div align="right">Latest 
          SEC Registration/Enabling Law or Charter :&nbsp;&nbsp;</div></td>
      <% strTemp = WI.fillTextValue("sec_reg");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(15));
	  %>
      <td colspan="2" class="body_font"><input name="sec_reg" type="text" size="16" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="31%" height="25" class="body_font"><div align="right">Date Granted 
          or Approved : &nbsp;</div></td>
      <% strTemp = WI.fillTextValue("date_sec");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(24));
	  %>
      <td width="16%"><input name="date_sec" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        <a href="javascript:show_calendar('form_.date_sec');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td width="30%" class="body_font"><div align="right">Year Established &nbsp;:&nbsp; 
        </div></td>
      <% strTemp = WI.fillTextValue("year_established");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(16));
	  %>
      <td width="23%"><input name="year_established" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','year_established')" onKeyUp="AllowOnlyInteger('form_','year_established')"></td>
    </tr>
    <tr> 
      <td height="25" class="body_font"><div align="right">Year Converted to University 
          Status&nbsp;: &nbsp;</div></td>
      <% strTemp = WI.fillTextValue("year_univ");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(17));
	  %>
      <td><input name="year_univ" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','year_univ')" onKeyUp="AllowOnlyInteger('form_','year_univ')"></td>
      <td class="body_font"><div align="right">Year Converted to College Status&nbsp;:&nbsp;</div></td>
      <% strTemp = WI.fillTextValue("year_college");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(18));
	  %>
      <td><input name="year_college" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','year_college')" onKeyUp="AllowOnlyInteger('form_','year_college')"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FEF7F5"> 
      <td colspan="4" class="body_font"><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
    <tr> 
      <% strTemp = WI.fillTextValue("head_name");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(19));
	  %>
      <td colspan="2" class="body_font">Name of Institutional Head : &nbsp;&nbsp; 
        <input name="head_name" type="text" size="24" maxlength="64" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="21%" class="body_font">Title of Head of Institution</td>
      <% strTemp = WI.fillTextValue("head_title");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(20));
	  %>
      <td width="20%"><input name="head_title" type="text" size="16" maxlength="16" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="35%" class="body_font">Highest Educational Attainment of the 
        Head</td>
      <% strTemp = WI.fillTextValue("head_educ_attain");
	  	if (strTemp.length() == 0 && vRetResult != null && vRetResult.size()> 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(21));
	  %>
      <td colspan="3"><input name="head_educ_attain" type="text" size="24" maxlength="32" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr align="right"> 
      <td colspan="4"><a href="javascript:UpdateXNames()"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">click 
        to update list of institutions former name(s)</font></td>
    </tr>
    <tr> 
      <td colspan="4"> <table width="90%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td width="32%" height="25" class="thinborder">&nbsp;List of Institution's 
              Former Names: </td>
            <td width="68%" class="thinborder"> <% if (vFormerNames != null && vFormerNames.size() > 0) {
	for (int i = 0; i <vFormerNames.size() ; i+=4) {%> &nbsp;<%=(String)vFormerNames.elementAt(i+1)%> <br> &nbsp;(<%=(String)vFormerNames.elementAt(i+2) +" - " + (String)vFormerNames.elementAt(i+3)%>) <br> <%
  } // end for loop
}else{ // end if vFormerName != null%> NA<%}%></td>
          </tr>
        </table></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FEF7F5"> 
      <td colspan="4" class="body_font"><!--DWLayoutEmptyCell-->&nbsp;</td>
    </tr>
    <tr> 
      <td class="body_font">Accomplished by<br></td>
      <td width="34%" class="body_font"><input name="accomplished" type="text" class="textbox" id="accomplished" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("accomplished")%>" size="24"></td>
      <td width="17%" class="body_font">Certified Correct:</td>
      <td width="34%"><input name="certified" type="text" class="textbox" id="certified" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certified")%>" size="24"></td>
    </tr>
    <tr> 
      <td width="15%" class="body_font">Designation</td>
      <td><input name="acc_design" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("acc_design")%>" size="24"></td>
      <td class="body_font">Designation</td>
      <td><input name="certify_design" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("certify_design")%>" size="24"></td>
    </tr>
    <tr> 
      <td class="body_font">Date </td>
<% strTemp = WI.fillTextValue("acc_date");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>	  
      <td><input name="acc_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="24">
        <font size="1">(mm/dd/yyyy)</font></td>
      <td class="body_font">Date </td>
<% strTemp = WI.fillTextValue("certify_date");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>		  
      <td><input name="certify_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="24">
        <font size="1">(mm/dd/yyyy)</font></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><div align="center"> 
          <% if (iAccessLevel > 1)  {
		  		if (vRetResult == null || vRetResult.size()  == 0) {
		  %>
          <a href="javascript:SaveRecord(0)"> <img src="../../../images/save.gif" border="0"></a> 
          <font size="1">click to save data </font> 
          <% }else{%>
          <a href="javascript:SaveRecord(1)"> <img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to save data </font> <a href="javascript:PrintPage()"> 
          <img src="../../../images/print.gif" border="0"></a> <font size="1">click 
          to save data </font> 
          <%   } // end ifelse (vRetResult == null || vRetResult.size() == 0)
   } // end iAccessLevel > 1  %>
        </div></td>
    </tr>
    <tr> 
      <td colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"> <div align="center"><font color="#FF0000" size="1">&nbsp;Note: 
          Anything without entry will be considered as <strong>NOT APPLICABLE</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
	<td height="25" colspan="2" bgcolor="#A49A6A"><font face="Arial, Helvetica, sans-serif">&nbsp;</font></td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" value="">
  <input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
