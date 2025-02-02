<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.form_.course_index[document.form_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		//alert(strURL);
		this.processRequest(strURL);
}</script>
<body bgcolor="#D2AE72" onLoad="document.form_.sub_index.focus()">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");

java.sql.ResultSet rs = null;
int iPageAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"), "-1"));
if(iPageAction == 0) {
	if(dbOP.executeUpdateWithTrans("delete from GWA_EXCLUDED where GWA_EX_INDEX="+WI.fillTextValue("info_index"),
		null,null,false) == -1)
		strErrMsg = "Delete operation failed.";
	else	
		strErrMsg = "Delete operation is successful.";
}
else if(iPageAction == 1) {
	String strSubIndex  = WI.fillTextValue("sub_index");
	if(strSubIndex.length() == 0)
		strErrMsg = "Subject can't be empty.";
	String strCourseIndex  = WI.getInsertValueForDB(WI.fillTextValue("course_index"), false, null);
	
	if(strErrMsg == null) {
		rs = dbOP.executeQuery("select sub_index from GWA_EXCLUDED where sub_index = "+strSubIndex+" and course_index_ is null");
		if(rs.next())
			strErrMsg = "Subject already added in the exclude list.";
		rs.close();
		if(strErrMsg == null) {
			iPageAction = 
				dbOP.executeUpdateWithTrans("insert into GWA_EXCLUDED (SUB_INDEX, course_index_, major_index_ ) values ("+
				strSubIndex+","+strCourseIndex+","+WI.getInsertValueForDB(WI.fillTextValue("major_index"), false, null)+")" ,null,null,false);
			if(iPageAction == -1)
				strErrMsg = "Error in adding subject.";
			else	
				strErrMsg = "Subject Added to exclude list.";
		} 
	}
}
boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;
%>

<form name="form_" action="./gwa_sub_excluded.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        GWA GRADE EQUIVALENT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" >Subject</td>
      <td width="80%" style="font-size:11px; color:blue; font-weight:bold">
<%
strTemp = "0";
if(bolIsBasic) 
	strTemp = "2";
%>
	  <select name="sub_index">
		<%=dbOP.loadCombo("sub_index","sub_code, sub_name",
			" from subject where IS_DEL="+strTemp+" and not exists (select * from GWA_EXCLUDED where GWA_EXCLUDED.sub_index = subject.sub_index and course_index_ is null) order by sub_code",WI.fillTextValue("sub_index"),false,false)%>	
	  </select>	  
	  
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onChange="ReloadPage();"> Is Basic?
	  
	  </td>
    </tr>
<%if(strSchCode.startsWith("CIT") && !bolIsBasic){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td >Course</td>
      <td >
	  <select name="course_index" onChange="loadMajor();">
          <option value="">ALL</option>
		<%=dbOP.loadCombo("course_index","course_code, course_name",
			" from course_offered where IS_DEL=0 and is_offered = 1 order by course_code",WI.fillTextValue("course_index"),false,false)%>	
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td >Major</td>
      <td >
<label id="load_major">
		<select name="major_index">
          <option value="">ALL</option>
<%if(WI.fillTextValue("course_index").length() > 0) {%>
          	<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_index") + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
<%}%>
		</select> 		  
</label>
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;<input type="image" src="../../../images/save.gif" border="0" onClick="document.form_.page_action.value=1">
	  <font size="1">Click to save information.</font></td>
    </tr>
    
    <tr> 
      <td colspan="4" height="10" >&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC">
      <td width="23%" height="25" class="thinborder">&nbsp;Sub Code </td>
      <td width="40%" class="thinborder">Sub Name </td>
<%if(strSchCode.startsWith("CIT")){%>
      <td width="20%" class="thinborder">Course</td>
<%}%>
      <td width="17%" class="thinborder">&nbsp;Remove </td>
    </tr>
<%rs = dbOP.executeQuery("select sub_code, sub_name, GWA_EX_INDEX,course_offered.course_code, major.course_code  from GWA_EXCLUDED "+
							"join subject on (GWA_EXCLUDED.sub_index = subject.sub_index)  "+
							"left join course_offered on (course_offered.course_index = course_index_)  "+
							"left join major on (major.major_index = major_index_) order by sub_code,course_offered.course_code");
  while(rs.next()){%>
    <tr >
      <td height="25" class="thinborder">&nbsp;<%=rs.getString(1)%></td>
      <td class="thinborder">&nbsp;<%=rs.getString(2)%></td>
<%if(strSchCode.startsWith("CIT")){%>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(rs.getString(4), "ALL")%> <%=WI.getStrValue(rs.getString(5), " - ", "","")%></td>
<%}%>
      <td class="thinborder">&nbsp;
	  	<input type="image" src="../../../images/delete.gif" 
		onClick="document.form_.page_action.value=0;document.form_.info_index.value=<%=rs.getString(3)%>"></td>
    </tr>
<%}
rs.close();%>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
