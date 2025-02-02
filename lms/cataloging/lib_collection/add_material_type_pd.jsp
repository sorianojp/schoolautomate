<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {

	if(strAction == 0){			
		if(!confirm("Please confirm to delete material type."))
			return;
		}

	document.form_.page_action.value = strAction;
	
		
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
		
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
	String strInfoIndex = null;
	String strPageAction = null;
	
	String strBookIndex = WI.fillTextValue("ACCESSION_NO");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_subj_headings.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_subj_headings.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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

	Search MTUpdate = new Search(request);
	
	strBookIndex = dbOP.mapBookIDToBookIndex(strBookIndex);
	
	if(strBookIndex == null) 
		strErrMsg = dbOP.getErrMsg();

	Vector vEditInfo  = new Vector();
	Vector vRetResult = new Vector();	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {		
		strPrepareToEdit = "0";	
		if(MTUpdate.operateOnMaterialTypePD(dbOP,Integer.parseInt(strTemp)) == null)
				strErrMsg = MTUpdate.getErrMsg();			
		else		
			{
				if(strTemp.compareTo("1") == 0)							
					strErrMsg = "Material Type successfully added.";		
				if(strTemp.compareTo("2") == 0)			
					strErrMsg = "Material Type successfully edited.";
				if(strTemp.compareTo("0") == 0)					
					strErrMsg = "Material Type successfully deleted.";
			}
		}	
	
		//search all material
		vRetResult = MTUpdate.operateOnMaterialTypePD(dbOP,4);
		if(vRetResult == null)
			strErrMsg = MTUpdate.getErrMsg();
			
		
//get vEditInfo If it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = MTUpdate.operateOnMaterialTypePD(dbOP,3);
	if(vEditInfo == null)
		strErrMsg = MTUpdate.getErrMsg();
}

%>


<body bgcolor="#F2DFD2">
<form action="./add_material_type_pd.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - UPDATE MATERIAL TYPE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <!--<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="2">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="20">&nbsp;</td>
      <td width="96%"><strong>BOOK ACCESSION NUMBER : <%=WI.fillTextValue("ACCESSION_NO")%></strong></td>
    </tr>
  </table>-->

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="30" colspan="3"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>      
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
	  <td height="30" width="10%">Material Type:</td>
	  <%if(vEditInfo!=null && vEditInfo.size()>0)
	  	strTemp = (String)vEditInfo.elementAt(1);
		else
		strTemp = WI.fillTextValue("material_type");	  
	  %>	
      <td width="96%" height="30"><textarea name="material_type"><%=strTemp%></textarea></td>		
    </tr>
	
<%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="51"></td>
      <td height="51" colspan="2"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit_recommend.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./add_material_type_pd.jsp?ACCESSION_NO=
		<%=response.encodeRedirectURL(WI.fillTextValue("ACCESSION_NO"))%>"><img src="../../images/cancel_recommend.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}//show only if authorized.%>
  </table>
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#FF0000">PHYSICAL DESCRIPTION MATERIAL TYPE LIST</font></div></td>
    </tr>
    <tr> 
      <td width="31%" height="25" class="thinborder"><div align="center"><font size="1"><strong> TYPE </strong></font></div></td>      
      <td class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 2){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>      
      <td width="17%" class="thinborder"><div align="center"><font size="1">&nbsp; 
          <%if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit_recommend.gif" width="53" height="28" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete_recommend.gif" width="53" height="26" border="0"></a> 
<%}%>
          </font></div></td>
    </tr>
<%}//for loop%>	
  </table>
<%}%>


<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="material_index" value="" />
<input type="hidden" name="ACCESSION_NO" value="<%=WI.fillTextValue("ACCESSION_NO")%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>