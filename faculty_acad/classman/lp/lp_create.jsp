<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMLessonPlan" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Syllabus","lp_create.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMLessonPlan cmLP = new CMLessonPlan();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmLP.operateOnCreateLP(dbOP, request, 1) == null) 
		strErrMsg = "Operation Successful.";
	else	
		strErrMsg = cmLP.getErrMsg();
}
Vector vLPHeaderList = null;
if(request.getParameter("page_action") != null) {
	vLPHeaderList = cmLP.operateOnLPMain(dbOP,request,4);///get header list.. 
	if(vLPHeaderList == null)
		strErrMsg = cmLP.getErrMsg();
}

if(vLPHeaderList != null) {
	vRetResult = cmLP.operateOnCreateLP(dbOP, request, 3);//show only one.. 
	if(vRetResult == null)
		strErrMsg = cmLP.getErrMsg();
}
	


%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
	function ReloadPage() {
		document.form_.page_action.value = "";
		document.form_.submit();
	}
	function PageAction(strAction) {
		document.form_.page_action.value = strAction;
	}
	function PrintPg() {
		var strPgLoc = "./lp_create_print.jsp?sub_index="+
			document.form_.sub_index[document.form_.sub_index.selectedIndex].value;
		window.open(strPgLoc,"myfile",'dependent=no,width=700,height=500,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	}
</script>
<body bgcolor="#93B5BB">
<form name="form_" method="post" action="./lp_create.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td width="100%" height="25" colspan="2" align="center"><font color="#FFFFFF"><strong>:::: LESSON PLAN MAINTENANCE PAGE::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"> &nbsp;Subject Code : <font size="1">
<input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');"
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	   onBlur="ReloadPage(); style.backgroundColor='#FFFFFF'" > 
(enter subject code to scroll the list)</font>
&nbsp;&nbsp;
<input type="submit" name="13" value="Reload Page" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('');"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;
        <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" onChange="ReloadPage();">
          <option value=""> .. select a subject .. </option>
		  <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=2 order by s_code",WI.fillTextValue("sub_index"), false)%>
        </select></td>
    </tr>
    <tr>
      <td height="25" colspan="2">Lesson Plan #: 
        <select name="order_no">
          <%
//if(vEditInfo!= null) 
//	strTemp = (String)vEditInfo.elementAt(2);
// else 
	strTemp = WI.fillTextValue("order_no");
int iOrderNo = Integer.parseInt(WI.getStrValue(strTemp, "1"));
for(int i = 1; i < 200; ++i) {
	if(iOrderNo == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
          <option value="<%=i%>"<%=strTemp%>><%=i%></option>
          <%}%>
        </select></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
<%if(vRetResult != null) {%>
    <tr> 
      <td colspan="2"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif"  border="0"></a><font size="1">click 
          to print lp_create</div></td>
    </tr>
<%}%>
    <tr valign="top"> 
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
<%if(vLPHeaderList != null && WI.fillTextValue("sub_index").length() > 0){//System.out.println(vRetResult);
	for(int i = 0,j=0; i < vLPHeaderList.size(); i +=4, ++j){
		strTemp = null;
		if(vRetResult != null && vRetResult.size() > 0){
			for(int k = 0; k < vRetResult.size(); k += 6) {
				if(vLPHeaderList.elementAt(i).equals(vRetResult.elementAt(k + 2))) {
					strTemp = (String)vRetResult.elementAt(k + 3);
					break;
				}
			}
		}
		if(strTemp == null && WI.fillTextValue("page_action").length() > 0)
			strTemp = WI.fillTextValue("lp_content"+j);%>
	<tr> 
      <td width="22%" valign="top" style="font-size:11px; font-weight:bold"><%=vLPHeaderList.elementAt(i + 1)%></td>
      <td width="31"><textarea name="lp_content<%=j%>" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
<input type="hidden" name="lp_main_i<%=j%>" value="<%=vLPHeaderList.elementAt(i)%>">	
<%}//end of for loop%>
<input type="hidden" name="max_disp" value="<%=vLPHeaderList.size()%>">
	<tr> 
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">
        <input type="submit" name="12" value="Update Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(1);">
      </div></td>
    </tr>
<%}//end of if condition%>    
  </table>

<table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="emp_id" value="<%=(String)request.getSession(false).getAttribute("userId")%>">
<input type="hidden" name="page_action">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>