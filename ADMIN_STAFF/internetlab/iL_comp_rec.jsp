<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.submit();
}
function updateList(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+
	"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeSetting,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET LAB OPERATION",
								"iL_comp_rec.jsp");
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
														"Internet Cafe Management",
														"INTERNET LAB OPERATION",request.getRemoteAddr(),
														"iL_comp_rec.jsp");
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

//end of authenticaion code.
ICafeSetting ICS = new ICafeSetting();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(ICS.computerInventory(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = ICS.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
//I have to get here information.
vRetResult = ICS.computerInventory(dbOP, request,4);
%>
<form action="./iL_comp_rec.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET LAB OPERATION - COMPUTER RECORDS PAGE::::</strong></font></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="2%" height="25">&nbsp; </td>
      <td height="25"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
    <tr>
      <td width="17%">&nbsp;</td>
      <td width="20%"><strong><font size="1">COMPUTER NAME&nbsp;&nbsp;: </font></strong></td>
      <td width="63%"><font size="1" > 
        <input name="comp_name" maxlength="32" value="<%=WI.fillTextValue("comp_name")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><strong><font size="1" >IP
        ADDRESS : </font></strong></td>
      <td><font size="1" > 
        <input name="ip_addr" type="text" maxlength="15" value="<%=WI.fillTextValue("ip_addr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="1" ><strong>STATUS
        : </strong></font></td>
      <td><font size="1" > 
          <select name="status">
            <option value="1">For use</option>
<%
strTemp = WI.fillTextValue("status");
if(strTemp.compareTo("0") == 0){%>
            <option value="0" selected>In Maintenance</option>
<%}else{%>
            <option value="0" >In Maintenance</option>
<%}%>          </select>
          </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="1" ><strong>LOCATION</strong></font>
        :</td>
      <td><font size="1" > 
        <%
strTemp = WI.fillTextValue("loc_index");
%>
        <select name="loc_index">
          <%=dbOP.loadCombo("location_index","location"," from IC_COMP_LOC order by location",strTemp,false)%> 
        </select>
        &nbsp;<a href='javascript:updateList("IC_COMP_LOC","LOCATION_INDEX","LOCATION","Computer Lab Location")'><img src="../../images/update.gif" border="0"></a> 
        <font size="1">update location</font> </font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"><strong><font size="1">REMARKS</font></strong><br> 
<%
strTemp=WI.fillTextValue("remark");
%>
	  <textarea name="remark" cols="62" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
      </td>
    </tr>
<%
if(iAccessLevel > 1){%>
    <tr>
      <td height="40" colspan="3"><div align="center">
	  <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a><font size="1" >click
          to save entries/changes 
		  <a href="./iL_comp_rec.jsp"><img src="../../images/cancel.gif" border="0"></a>click to
          clear or cancel entries</font></div></td>
    </tr>
<%}%>

  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="5" cellspacing="5" bgcolor="#FFFFFF">
    <tr> 
      <td width="62%" height="25">Display Computer list per Location <font size="1" >
        <select name="show_by_loc" onChange="ReloadPage();">
		<option value="">ALL</option>
          <%=dbOP.loadCombo("location_index","location"," from IC_COMP_LOC order by location",
		  WI.fillTextValue("show_by_loc"),false)%> 
        </select>
        </font></td>
      <td width="31%" height="25"><a href="PrintPage();"><img src="../../images/print.gif" border="0"></a><font size="1">click 
        to print the list</font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFF9F" > 
      <td height="25" colspan="6" class="thinborder"><div align="center"><font color="#000000"><strong>LIST 
          OF COMPUTERS IN THE INTERNET CAFE</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="6" class="thinborder"><strong><font size="1">TOTALS : <%=(String)vRetResult.elementAt(0)%> (For use : <%=(String)vRetResult.elementAt(1)%> ; For Maintenace : <%=(String)vRetResult.elementAt(2)%>)</font></strong></td>
    </tr>
    <tr > 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong><font size="1">COMPUTER 
          NAME</font></strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong><font size="1" >IP ADDRESS</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1" ><strong>STATUS</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1" ><strong>LOCATION</strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">REMARKS</font></strong></div></td>
      <td width="11%" class="thinborder">&nbsp;</td>
    </tr>
<%
for(int i = 3; i < vRetResult.size(); i += 7){%>
    <tr > 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"&nbsp")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;
<%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'>
	  	<img src="../../images/delete.gif" border="0"></a>
<%}%>		</td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="44" colspan="7"><div align="center"><img src="../../images/print.gif"><font size="1">click
          to print the list</font></div></td>
    </tr>
  </table>
<%}//if vRetResult not null
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="7" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=WI.fillTextValue("prepareToEdit")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>