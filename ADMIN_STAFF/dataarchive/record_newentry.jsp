<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Data Archive New Record Entry Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
function FocusID() {
	document.form_.record_no.focus();
}
//strInfoIndex is not null for delete action.
function PageAction(strInfoIndex, strAction) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	if(strAction =="1")
		document.form_.hide_save.src = "../../images/blank.gif";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function updateList(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+
	"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function updateListNew(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function CancelRecord() {
	location = "./record_newentry.jsp";
}
function SearchRecord() {
	var pgLoc = "./search_record.jsp?opner_info=fa_payment.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,dataarchive.DAMain,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null; String strTemp3 = null;
	Vector vRetResult = null;
	boolean bolRetainOldVal = true;//if true, use WI.fillTextValue();

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Data Archive-New Entry","record_newentry.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Data Archive","New Archive Entry",request.getRemoteAddr(),
															"record_newentry.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	
DAMain dMain = new DAMain();	
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(dMain.operateOnRecordEntry(dbOP,request,Integer.parseInt(strTemp)) == null)
		strErrMsg = dMain.getErrMsg();
	else	
		strErrMsg = "Operation successful.";	
}
//now get the information.
vRetResult = dMain.operateOnRecordEntry(dbOP,request,3);
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("reload_page").length() ==0)
	bolRetainOldVal = false;

%>
<form name="form_" method="post" action="./record_newentry.jsp">
<table width="100%" border="0">
  <tr>
    <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>::: 
          ARCHIVE ENTRY :::</strong></font></div></td>
  </tr>
</table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
<%
if(strErrMsg != null){%>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
<%}%>
    <tr> 
      <td width="19%" height="25">Record # </td>
      <td width="23%"><input name="record_no" type="text" size="20" maxlength="32"
	  value ="<%=WI.fillTextValue("record_no")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="13%"><a href="javascript:SearchRecord();"><img src="../../images/search.gif" border="0"></a></td>
      <td width="45%"><input type="image" src="../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td width="19%" height="25">Category </td>
      <td colspan="3"><select name="catg_index">
          <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME",
                   " from DA_CATG where is_valid = 1 and is_del=0 order by catg_name", 
                   WI.fillTextValue("catg_index"),false)%> </select> 
				   <a href='javascript:updateListNew("DA_CATG","CATG_INDEX","CATG_NAME","ARCHIVE%20CATEGORY",
					"DA_RECORD","catg_index"," and DA_RECORD.is_valid = 1","","catg_index")'><img src="../../images/update.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="2"><div align="center"><strong><font color="#FFFFFF">ARCHIVE 
          RECORD INFORMATION</font></strong></div></td>
    </tr>
    <tr> 
      <td>ARCHIVE FORMAT</td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("format_index");
else	
	strTemp = (String)vRetResult.elementAt(2);
%>	  <select name="format_index">
          <%=dbOP.loadCombo("FORMAT_INDEX","FILE_FORMAT"," from DA_FORMAT order by FILE_FORMAT", 
                   strTemp,false)%> </select>
        <a href='javascript:updateList("DA_FORMAT","FORMAT_INDEX","FILE_FORMAT","FILE FORMAT")'><img src="../../images/update.gif" border="0"></a> 
        (pdf, doc, jpeg)</td>
    </tr>
    <tr> 
      <td>CD VOLUME #</td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("cd_vol_no");
else	
	strTemp = (String)vRetResult.elementAt(3);
%>	  <input type="text" name="cd_vol_no"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr> 
      <td>STORAGE LOC</td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("storage_loc");
else	
	strTemp = (String)vRetResult.elementAt(4);
%>	  <input type="text" name="storage_loc"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr> 
      <td>RECORD INFORMATION</td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("record_info");
else	
	strTemp = (String)vRetResult.elementAt(5);
%>	  <textarea name="record_info" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  class="textbox"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td colspan="2" bgcolor="#B9B292" height="25"><div align="center"><strong><font color="#FFFFFF">PERSONAL 
          INFORMATION</font></strong></div></td>
    </tr>
    <tr> 
      <td width="19%"> Course </td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("course_index");
else	
	strTemp = (String)vRetResult.elementAt(6);
%>	  <select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 						" order by course_name asc", strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td> Major </td>
      <td><select name="major_index">
          <option></option>
          <%
if(WI.fillTextValue("course_index").length()>0){
	strTemp = " from major where IS_DEL=0 and course_index="+strTemp+" order by major_name asc";
if(bolRetainOldVal)
	strTemp2 = WI.fillTextValue("major_index");
else	
	strTemp2 = (String)vRetResult.elementAt(7);
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, strTemp2, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td> Year Grad. </td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("year_grad");
else	
	strTemp = (String)vRetResult.elementAt(8);
%>	  <input type="text" name="year_grad" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
    </tr>
    <tr> 
      <td>College</td>
      <td><select name="c_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("c_index");
else	
	strTemp = (String)vRetResult.elementAt(9);

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select> </td>
    </tr>
    <tr> 
      <td><%=strTemp2%></td>
      <td>
        <select name="d_index">
          <option value="">N/A</option>
<%
strTemp3 = "";
if(bolRetainOldVal)
	strTemp3 = WI.fillTextValue("d_index");
else	
	strTemp3 = (String)vRetResult.elementAt(10);

if(strTemp2.startsWith("O"))//office
	strTemp = " from department where IS_DEL=0 and c_index is null or c_index=0 order by d_name asc";
else	
	strTemp = " from department where IS_DEL=0 and c_index = "+strTemp+" order by d_name asc";
%>
          <%=dbOP.loadCombo("d_index","d_NAME",strTemp,strTemp3, false)%> 
        </select>
      </td>
    </tr>
    <tr> 
      <td> ID </td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("id_number");
else	
	strTemp = (String)vRetResult.elementAt(11);
%>	  <input type="text" name="id_number"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td> LName, FName, MName</td>
      <td>
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("lname");
else	
	strTemp = (String)vRetResult.elementAt(14);
%>	  <input type="text" name="lname"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("fname");
else	
	strTemp = (String)vRetResult.elementAt(12);
%>	  <input type="text" name="fname"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
<%
if(bolRetainOldVal)
	strTemp = WI.fillTextValue("mname");
else	
	strTemp = (String)vRetResult.elementAt(13);
%>        <input type="text" name="mname"
	  value ="<%=WI.getStrValue(strTemp)%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19%">&nbsp;</td>
      <td width="81%"><font size="1">
        <% if (iAccessLevel > 1){
	if(vRetResult == null || vRetResult.size() ==0) {%>
        <a href='javascript:PageAction("",1);'><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        click to save entries&nbsp; 
        <%}else{%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(0)%>",2);'><img src="../../images/edit.gif" border="0"></a> 
        click to save changes
        <%if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(0)%>",0);'><img src="../../images/delete.gif" border="0"></a> 
        click to delete record
        <%}}}%>
		<a href='javascript:CancelRecord();'><img src="../../images/cancel.gif" border="0"></a>
		click to cancel and clear entries</font>
      </td>
    </tr>
  </table>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="reload_page">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
