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
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm("Are you sure you want to remove this record."))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	document.form_.submit();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}


</script>

<body bgcolor="#D2AE72" onLoad="document.form_.emp_id.focus();">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertSem ={"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"set_as_non_employee.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSQLQuery    = null;
java.sql.ResultSet rs = null;
Vector vRetResult     = new Vector();
Vector vRetResult2    = new Vector();//list of non-employees.

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(strTemp.equals("0")) {
		strSQLQuery = "update user_table set is_valid = 1 where user_index = "+WI.fillTextValue("info_index")+" and is_valid = 2";
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1) {
			strErrMsg = "Error in updating information.";
			System.out.println(strSQLQuery);
		}
		else
			strErrMsg = "Non-Employee successfully tagged as Employee.";
	}
	else {//set as Non-Employee.
		int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
		strSQLQuery = null;
		for(int i = 0; i < iMaxDisp; ++i) {
			strTemp = WI.fillTextValue("_"+i);
			if(strTemp.length() == 0) 
				continue;
			if(strSQLQuery == null)
				strSQLQuery = strTemp;
			else	
				strSQLQuery +=","+strTemp;
		}
		if(strSQLQuery == null)
			strErrMsg = "Please select at least one employee to proceed.";
		else {
			strSQLQuery = "update user_table set is_valid = 2 where is_valid = 1 and user_index in ("+strSQLQuery+")";
			if(dbOP.executeUpdateWithTrans(strSQLQuery, (String)request.getSession(false).getAttribute("login_log_index"), "USER_TABLE", true) == -1) {
				strErrMsg = "Error in updating information.";
				System.out.println(strSQLQuery);
			}
			else 
				strErrMsg = "Employee successfully tagged as Non-Employee.";
		}
	}

}
strSQLQuery    = "";
///view one or view all. 
strTemp = WI.fillTextValue("show_result");
if(strTemp.equals("1")) {
	String strCollegeIndex = WI.fillTextValue("c_index");
	String strDeptIndex    = WI.fillTextValue("d_index");
	
	if(strCollegeIndex.length() == 0 && strDeptIndex.length() == 0 && WI.fillTextValue("emp_id").length() == 0)
		strErrMsg = "Please select at least one college/dept/enter employee ID.";
	else {
		if(strCollegeIndex.length() > 0) 
			strSQLQuery = " and info_faculty_basic.c_index = "+strCollegeIndex;
		if(strDeptIndex.length() > 0) 
			strSQLQuery += " and info_faculty_basic.d_index = "+strDeptIndex;
		if(WI.fillTextValue("emp_id").length() > 0) 
			strSQLQuery += " and user_table.id_number like '"+WI.fillTextValue("emp_id")+"%' ";
		
		strSQLQuery = "select user_table.user_index, id_number, fname, mname, lname from user_Table "+
						"join info_faculty_basic on (info_faculty_basic.user_index = user_table.user_index) "+
						" where user_table.is_valid = 1 and info_faculty_basic.is_valid = 1 and (expire_date is null or expire_date > '"+
						WI.getTodaysDate()+"') "+strSQLQuery+" order by lname, fname";//System.out.println(strSQLQuery);
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vRetResult.addElement(rs.getString(1));//[0] user_index
			vRetResult.addElement(rs.getString(2));//[1] id_number
			vRetResult.addElement(WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));//[2] Name.
		}
		rs.close();
	}
	
}
else if(strTemp.equals("2")) {
	strSQLQuery = "select user_table.user_index, id_number, fname, mname, lname from user_Table "+
					"join info_faculty_basic on (info_faculty_basic.user_index = user_table.user_index) "+
					" where user_table.is_valid = 2 and info_faculty_basic.is_valid = 1 and (expire_date is null or expire_date > '"+
					WI.getTodaysDate()+"') order by lname, fname";//System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vRetResult2.addElement(rs.getString(1));//[0] user_index
		vRetResult2.addElement(rs.getString(2));//[1] id_number
		vRetResult2.addElement(WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));//[2] Name.
	}
	rs.close();
}




if(strErrMsg == null) 
	strErrMsg = "";
%>
<form name="form_" action="./set_as_non_employee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: SET USER AS NON-EMPLOYEE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="28" width="1%">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=strErrMsg%></b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td colspan="3">
<%
String strCollegeIndex = WI.fillTextValue("c_index");
%>
	  <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select>	</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department</td>
      <td colspan="3">
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	  	  
	  	<label id="load_dept">
		<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
          <%}%>
        </select> 
		</label>	  </td>
    </tr>
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td width="15%">Employee ID </td>
      <td width="22%"> </select> <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUp="AjaxMapName(1);"></td>
      <td width="8%"><label id="coa_info" style="position:absolute; width:350px;"></label></td>
      <td width="54%"> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <input type="button" name="proceed_btn" value=" Show List of Employees " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="document.form_.show_result.value='1';document.form_.submit();">	  </td>
      <td>&nbsp;</td>
      <td align="right">
	  <input type="button" name="proceed_btn" value=" Show List of Non-Employees(All) " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="document.form_.show_result.value='2';document.form_.submit();">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:9px; color:#0000FF; font-weight:bold">Note: If System does not save successfully, change the data type of is_valid of USER_TABLE TABLE to tinyint</td>
    </tr>
  </table>
 <%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">LIST OF EMPLOYEE</td>
    </tr>
    <tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
      <td class="thinborder" height="25" style="font-size:9px;" width="25%">ID NUMBER</td>
      <td class="thinborder" style="font-size:9px;" width="60%">EMPLOYEE NAME</td>
      <td class="thinborder" style="font-size:9px;" width="15%">SELECT</td>
    </tr>
<%
int iCount = 0;
for(int i = 0; i < vRetResult.size(); i += 3){%>
    <tr>
      <td class="thinborder" height="25" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;" align="center">
	  <input type="checkbox" name="_<%=iCount++%>" value="<%=vRetResult.elementAt(i)%>">
	  
	  </td>
    </tr>
<%}%>
<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center">
	  <input type="button" name="proceed_btn_" value=" Set as Non-Employee " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="document.form_.page_action.value='1';document.form_.submit();">
	  </td>
    </tr>
  </table>
 <%}%>
 <%if(vRetResult2 != null && vRetResult2.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="4" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">LIST OF NON-EMPLOYEE</td>
    </tr>
    <tr style="font-weight:bold" align="center" bgcolor="#FFFFCC">
      <td class="thinborder" height="25" style="font-size:9px;" width="25%">ID NUMBER</td>
      <td class="thinborder" style="font-size:9px;" width="60%">EMPLOYEE NAME</td>
      <td class="thinborder" style="font-size:9px;" width="15%">SELECT</td>
    </tr>
<%
for(int i = 0; i < vRetResult2.size(); i += 3){%>
    <tr>
      <td class="thinborder" height="25" style="font-size:9px;">&nbsp;<%=vRetResult2.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=vRetResult2.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;" align="center">
		<a href="javascript:PageAction('0', '<%=vRetResult2.elementAt(i)%>')">
		  <img src="../../../../images/delete.gif" border="0">
		</a>
	  </td>
    </tr>
<%}%>
  </table>	
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" align="center">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="page_action">
 <input type="hidden" name="info_index">
 <input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
