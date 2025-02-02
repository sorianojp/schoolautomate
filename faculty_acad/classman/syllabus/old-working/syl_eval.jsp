<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function GoToParentWnd() {
	//to get off focus.
	if(document.form_.reload_page.value == '')
		window.opener.childWnd = null;
	window.opener.document.form_.eval_technique.value  = document.form_.eval_detail.value;
}
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	document.form_.reload_page.value = '';
	document.form_.submit();
}
function AddToList() {

	strAddToList = document.form_.sel_method[document.form_.sel_method.selectedIndex].text;
	if(document.form_.sel_method.selectedIndex == 0) {
		alert("select a Method to add to list.");
		return;
	}
	if(document.form_.eval_detail.value.length > 0) 
		document.form_.eval_detail.value = document.form_.eval_detail.value + "\r\n"+strAddToList;
	else	
		document.form_.eval_detail.value = strAddToList;
		
}
function SelMethodChanged() {
	if(document.form_.sel_method.selectedIndex == 0) 
		document.form_.eval_method.value = "";
	else	
		document.form_.eval_method.value = document.form_.sel_method[document.form_.sel_method.selectedIndex].text;
}
</script>


<%@ page language="java" import="utility.*"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strMethodCreated = null;
	
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
	if(iAccessLevel == -1 || iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	java.sql.ResultSet rs = null;
	try{
		dbOP = new DBOperation();
		
		if(request.getParameter("page_action") == null) {
			rs = dbOP.executeQuery("select INST_TECHNIQUE from CM_SYL_MAIN where sub_index = "+
				WI.fillTextValue("sub_index"));
			if(rs.next())
				strMethodCreated = rs.getString(1);
			rs.close();
		}
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

	
	if(WI.fillTextValue("page_action").length() > 0) {
		//end of authenticaion code.
		try{
			strTemp = WI.fillTextValue("eval_method");
			if(strTemp.length() > 0) {
				strTemp = WI.getInsertValueForDB(strTemp, true, null);
				rs = dbOP.executeQuery("Select * from CM_SYL_PRELOAD_EVALMETHOD where METHOD_NAME = "+
								strTemp);
				if(!rs.next()) {
					rs.close();
					///page action 2 = edit method name.
					if(WI.fillTextValue("sel_method").length() > 0 && WI.fillTextValue("page_action").equals("2")) //edit.
						dbOP.executeUpdateWithTrans("update CM_SYL_PRELOAD_EVALMETHOD set METHOD_NAME="+
							strTemp+" where EVAL_METHOD_INDEX="+WI.fillTextValue("sel_method"), null, null, false);
					else			
						dbOP.executeUpdateWithTrans("insert into CM_SYL_PRELOAD_EVALMETHOD (METHOD_NAME) values ("+
							strTemp+") ", null, null, false);
					
				}
				else
					rs.close();
			
			}
			
		}
		catch(Exception exp) {
			exp.printStackTrace();
			if(strErrMsg == null)
				strErrMsg = "Error in SQL Query. Please try again.";
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
			<%
			return;
		}
	}
	

%>

<body bgcolor="#93B5BB" onUnload="GoToParentWnd();">
<form name="form_" method="post" action="./syl_eval.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2">
      <td height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
           EVALUATION TECHNIQUE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="19%">Evaluation Technique </td>
      <td width="81%">
          <select name="sel_method" onChange="SelMethodChanged();">
            <option value="">Select Method or Add New</option>
<%=dbOP.loadCombo("EVAL_METHOD_INDEX","method_name "," from CM_SYL_PRELOAD_EVALMETHOD order by method_name",WI.fillTextValue("EVAL_METHOD_INDEX"), false)%>
          </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input type="text" name="eval_method" class="textbox" size="45" maxlength="128">
      <a href="javascript:PageAction(1);"><img src="../../../images/update.gif" border="0"></a>
      &nbsp;&nbsp;
	  <a href="javascript:PageAction(2);"><img src="../../../images/edit.gif" border="0"></a>
	  <br>
      NOTE : <br>
      1. 
      To add a new Method, type here the name and click update. <br>
      2. To Edit a Method name, select Method name and change it's name and click update.<br>
      3. To add the method name to syllabus, select a method name and click Add button below. </td>
    </tr>
    <tr>
      <td colspan="2"> <div align="center">
	  <a href="javascript:AddToList();"><img src="../../../images/add.gif" border="0"></a>
	  <font size="1">Add to list.</font>
	  </div></td>
    </tr>
    <tr>
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#BDD5DF">
      <td height="25" colspan="2"><div align="center"><strong>LIST OF APPLICABLE
          EVALUATION TECHNIQUES TO BE USED</strong></div></td>
    </tr>
    <tr>
      <td width="19%" height="25">&nbsp;</td>
      <td width="81%" valign="top">NOTE : After adding all Methods, close this window. <a href="javascript:self.close();">Click to Close</a> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">
<%
strTemp = strMethodCreated;
if(strTemp == null) 	
	strTemp = WI.fillTextValue("eval_detail");
%>
	  <textarea name="eval_detail" cols="75" rows="10" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.fillTextValue("eval_detail")%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">
	  <a href="#"><img src="../../../images/clear.gif" border="0" onClick="document.form_.eval_detail.value='';"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="reload_page" value="">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
</form>
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
%>