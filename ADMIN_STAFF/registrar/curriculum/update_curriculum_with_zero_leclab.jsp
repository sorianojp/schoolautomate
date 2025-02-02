<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>
<script language="JavaScript">
</script>

<body bgcolor="#D2AE72" onLoad="document.ccourse.course_code.focus();">
<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-upload Migrated Curriculum","update_curriculum_with_zero_leclab.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","CURRICULUM",request.getRemoteAddr(),
														"update_curriculum_with_zero_leclab.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

strErrMsg = null; //if there is any message set -- show at the bottom of the page.
Vector vRetResult = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;
//System.out.println(WI.fillTextValue("page_action"));
if(WI.fillTextValue("page_action").length() > 0) {
	String strLecU = null;
	String strLabU = null;
	String strLecH = null;
	String strLabH = null;
	
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
	String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
	for(int i = 0; i < iMaxDisp; ++i) {
		strLecU = WI.fillTextValue("lecu_"+i);
		strLabU = WI.fillTextValue("labu_"+i);
		strLecH = WI.fillTextValue("lech_"+i);
		strLabH = WI.fillTextValue("labh_"+i);
		strTemp = WI.fillTextValue("subi_"+i);
		
		if(strLecU.length() == 0 && strLabU.length() == 0 && strLecH.length() == 0 && strLabH.length() == 0)
			continue;		
		if(strTemp.length() == 0) 
			continue;
			
		if(strLecU.length() == 0)
			strLecU = "0.0";
		if(strLabU.length() == 0)
			strLabU = "0.0";
		if(strLecH.length() == 0)
			strLecH = "0.0";
		if(strLabH.length() == 0)
			strLabH = "0.0";
		
		//I have to get the list of curriculums having 0 units.
		strSQLQuery = "update curriculum set lec_unit = "+strLecU+", lab_unit = "+strLabU+" , hour_lec = "+strLecH+" , hour_lab ="+strLabH+
						", last_mod_date ='"+WI.getTodaysDate()+"', last_mod_by="+strAuthID+
						" where lec_unit = 0 and lab_unit = 0 and hour_lec = 0 and hour_lab = 0 and sy_from < 1980 and encoded_by = 0 and sub_index = "+strTemp;
		System.out.println(strSQLQuery);
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
}

//view all pending.. 
/**
update here masteral curriculum that is migrated and set the unit to 0
**/
strSQLQuery = "update CCULUM_MASTERS set unit = (select max(credit_earned) from g_sheet_final where s_index = sub_index and is_valid = 1) where unit = 0 and cy_from < 1980";
dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

strSQLQuery = "select distinct subject.sub_index, sub_code, sub_name from subject "+
				"join g_sheet_final on (g_sheet_final.s_index = subject.sub_index) "+
				"join curriculum on (curriculum.cur_index = g_sheet_final.cur_index) "+
				"join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = g_sheet_final.cur_hist_index) "+
				"where g_sheet_final.is_valid = 1 and lec_unit = 0 and lab_unit = 0 and hour_lec = 0 and hour_lab = 0 "+
				"and curriculum.sy_from < 1980 and credit_earned > 0 and course_type <> 1 and course_type <> 2 and curriculum.encoded_by = 0 "+
				"order by sub_code";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));//[0] sub_index
	vRetResult.addElement(rs.getString(2));//[1] sub_code
	vRetResult.addElement(rs.getString(3));//[2] sub_name
}
rs.close();

%>

<form name="form_" action="./update_curriculum_with_zero_leclab.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong>:::: UPDATE SUBJECT UNITS HAVING ZERO LEC/LAB UNITS ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="67%"  style="font-size:11px; font-weight:bold; color:#0000FF">Note: You may click Update button anytime even the list is partially filled up</td>
      <td width="33%" height="25" align="right">
	  <input name="Submit" type="submit" style="font-size:16px; height:27px;border: 1px solid #FF0000;" value="Update Lec/Lab unit-hours" onClick="document.form_.page_action.value='1'"></td>
    </tr>
    
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2"><div align="center">LIST OF SUBJECTS HAVING ZERO LEC/LAB UNITS</div></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFDF" align="center" style="font-weight:bold">
      <td width="5%" class="thinborder"><font size="1">COUNT</font></td>
      <td width="15%" height="25" class="thinborder"><font size="1">SUBJECT CODE</font></td>
      <td width="45%" class="thinborder"><font size="1">SUBJECT NAME</font></td>
      <td width="10%" class="thinborder"><font size="1">LEC UNIT</font></td>
      <td width="10%" class="thinborder"><font size="1">LAB UNIT</font></td>
      <td width="10%" class="thinborder"><font size="1">LEC HOURS</font></td>
      <td width="10%" class="thinborder"><font size="1">LAB HOURS</font></td>
    </tr>
<%for(int i = 0 ; i< vRetResult.size();  i += 3){%>
    <tr>
      <td class="thinborder"><%=i/3 + 1%>.</td>
      <td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%><input type="hidden" name="subi_<%=i/3%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><input size="4" type="text" name="lecu_<%=i/3%>"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborder"><input size="4" type="text" name="labu_<%=i/3%>"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborder"><input size="4" type="text" name="lech_<%=i/3%>"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborder"><input size="4" type="text" name="labh_<%=i/3%>"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=vRetResult.size()/3%>">
  </table>
 <%}//end of showing if there is course created.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
 <input type="hidden" name="page_action">
</form>
</body>
</html>
